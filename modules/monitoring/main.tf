# Monitoring module for EKS

# Retrieve current AWS account data
data "aws_caller_identity" "current" {}

# Current AWS region data
data "aws_region" "current" {}

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