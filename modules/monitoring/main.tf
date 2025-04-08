# Monitoring module for EKS

# Retrieve current AWS account data
data "aws_caller_identity" "current" {}

# Current AWS region data
data "aws_region" "current" {}

locals {
  # Service account names
  prometheus_sa_name   = "prometheus-server"
  
  # Namespaces for components
  monitoring_namespace = "monitoring"
}

# Create a namespace for monitoring in Kubernetes
resource "kubernetes_namespace" "monitoring" {
  count = var.create_monitoring_namespace ? 1 : 0
  
  metadata {
    name = local.monitoring_namespace
    
    labels = {
      name = local.monitoring_namespace
    }
  }
}

# Create IAM role for Prometheus
resource "aws_iam_role" "prometheus_role" {
  count = var.install_prometheus ? 1 : 0
  
  name = "${var.prefix}-prometheus-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.eks_oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(var.eks_oidc_provider_arn, "/^(.+)\\/(.+)$/", "$2")}:sub": "system:serviceaccount:${local.monitoring_namespace}:${local.prometheus_sa_name}"
        }
      }
    }]
  })
}

# Create IAM policy for Prometheus
resource "aws_iam_policy" "prometheus_policy" {
  count = var.install_prometheus ? 1 : 0
  
  name        = "${var.prefix}-prometheus-policy-${var.environment}"
  description = "Policy for Prometheus"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "tag:GetResources"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach policy to Prometheus role
resource "aws_iam_role_policy_attachment" "prometheus_attachment" {
  count = var.install_prometheus ? 1 : 0
  
  role       = aws_iam_role.prometheus_role[0].name
  policy_arn = aws_iam_policy.prometheus_policy[0].arn
}

# Create Kubernetes service account for Prometheus
resource "kubernetes_service_account" "prometheus_sa" {
  count = var.install_prometheus ? 1 : 0
  
  metadata {
    name      = local.prometheus_sa_name
    namespace = local.monitoring_namespace
    
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.prometheus_role[0].arn
    }
  }
  
  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

# Install Prometheus via Helm
resource "helm_release" "prometheus" {
  count = var.install_prometheus ? 1 : 0
  
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = local.monitoring_namespace
  version    = var.prometheus_chart_version
  
  set {
    name  = "serviceAccounts.server.create"
    value = "false"
  }
  
  set {
    name  = "serviceAccounts.server.name"
    value = local.prometheus_sa_name
  }
  
  set {
    name  = "server.persistentVolume.enabled"
    value = var.prometheus_persistent_storage
  }
  
  set {
    name  = "server.persistentVolume.size"
    value = var.prometheus_storage_size
  }
  
  # Resource settings
  set {
    name  = "server.resources.requests.cpu"
    value = var.prometheus_cpu_request
  }
  
  set {
    name  = "server.resources.requests.memory"
    value = var.prometheus_memory_request
  }
  
  set {
    name  = "server.resources.limits.cpu"
    value = var.prometheus_cpu_limit
  }
  
  set {
    name  = "server.resources.limits.memory"
    value = var.prometheus_memory_limit
  }
  
  # Data retention settings
  set {
    name  = "server.retention"
    value = var.prometheus_retention_period
  }
  
  # Set service as LoadBalancer if external access is required
  set {
    name  = "server.service.type"
    value = var.prometheus_service_type
  }
  
  depends_on = [
    kubernetes_service_account.prometheus_sa,
    kubernetes_namespace.monitoring
  ]
}

# Create CloudWatch Log Group for EKS cluster logs
resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = var.retention_in_days
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-eks-cluster-logs-${var.environment}"
    }
  )
}

# Create CloudWatch Dashboard for EKS cluster monitoring
resource "aws_cloudwatch_dashboard" "eks_dashboard" {
  count = var.create_cloudwatch_dashboard ? 1 : 0
  
  dashboard_name = "${var.prefix}-eks-dashboard-${var.environment}"
  
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/EKS", "cluster_failed_node_count", "ClusterName", "${var.eks_cluster_name}" ],
          [ ".", "cluster_node_count", ".", "." ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "${data.aws_region.current.name}",
        "title": "Cluster Node Count",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/EKS", "pod_cpu_utilization", "ClusterName", "${var.eks_cluster_name}" ],
          [ ".", "pod_memory_utilization", ".", "." ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "${data.aws_region.current.name}",
        "title": "Pod CPU and Memory Utilization",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/EKS", "node_cpu_utilization", "ClusterName", "${var.eks_cluster_name}" ],
          [ ".", "node_memory_utilization", ".", "." ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "${data.aws_region.current.name}",
        "title": "Node CPU and Memory Utilization",
        "period": 300,
        "stat": "Average"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 6,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/EKS", "cluster_autoscaler_upscaled", "ClusterName", "${var.eks_cluster_name}" ],
          [ ".", "cluster_autoscaler_downscaled", ".", "." ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "${data.aws_region.current.name}",
        "title": "Cluster Autoscaler Activity",
        "period": 300,
        "stat": "Sum"
      }
    }
  ]
}
EOF
}

# Create CloudWatch Alarms for critical EKS metrics
resource "aws_cloudwatch_metric_alarm" "node_cpu_high" {
  count = var.create_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${var.prefix}-eks-node-cpu-high-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "node_cpu_utilization"
  namespace           = "AWS/EKS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors EKS node CPU utilization"
  
  dimensions = {
    ClusterName = var.eks_cluster_name
  }
  
  alarm_actions = var.cloudwatch_alarm_actions
  ok_actions    = var.cloudwatch_alarm_actions
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-eks-node-cpu-high-${var.environment}"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "node_memory_high" {
  count = var.create_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${var.prefix}-eks-node-memory-high-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "node_memory_utilization"
  namespace           = "AWS/EKS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors EKS node memory utilization"
  
  dimensions = {
    ClusterName = var.eks_cluster_name
  }
  
  alarm_actions = var.cloudwatch_alarm_actions
  ok_actions    = var.cloudwatch_alarm_actions
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-eks-node-memory-high-${var.environment}"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "failed_nodes" {
  count = var.create_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${var.prefix}-eks-failed-nodes-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "cluster_failed_node_count"
  namespace           = "AWS/EKS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "This alarm monitors EKS failed node count"
  
  dimensions = {
    ClusterName = var.eks_cluster_name
  }
  
  alarm_actions = var.cloudwatch_alarm_actions
  ok_actions    = var.cloudwatch_alarm_actions
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-eks-failed-nodes-${var.environment}"
    }
  )
}

