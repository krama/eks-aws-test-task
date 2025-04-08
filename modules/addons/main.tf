# EKS Add-ons Module

# Retrieve current AWS account data
data "aws_caller_identity" "current" {}

# Current AWS region data
data "aws_region" "current" {}

locals {
  # Service account names
  cluster_autoscaler_sa_name = "cluster-autoscaler"
  metrics_server_sa_name     = "metrics-server"
  
  # Namespaces for components
  kube_system_namespace      = "kube-system"
  monitoring_namespace       = "monitoring"
}

# AWS EKS Managed Add-ons
resource "aws_eks_addon" "eks_addons" {
  for_each = var.aws_eks_addons

  cluster_name                = var.eks_cluster_name
  addon_name                  = each.value.addon_name
  addon_version               = lookup(each.value, "addon_version", null)
  resolve_conflicts           = lookup(each.value, "resolve_conflicts", "OVERWRITE")
  service_account_role_arn    = lookup(each.value, "service_account_role_arn", null)
  
  tags = merge(
    var.tags,
    {
      "eks_addon" = each.value.addon_name
    }
  )
}

# Create IAM Role for Cluster Autoscaler
resource "aws_iam_role" "cluster_autoscaler_role" {
  count = var.install_cluster_autoscaler ? 1 : 0
  
  name = "${var.prefix}-cluster-autoscaler-role-${var.environment}"
  
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
          "${replace(var.eks_oidc_provider_arn, "/^(.+)\\/(.+)$/", "$2")}:sub": "system:serviceaccount:${local.kube_system_namespace}:${local.cluster_autoscaler_sa_name}"
        }
      }
    }]
  })
}

# Create IAM Policy for Cluster Autoscaler
resource "aws_iam_policy" "cluster_autoscaler_policy" {
  count = var.install_cluster_autoscaler ? 1 : 0
  
  name        = "${var.prefix}-cluster-autoscaler-policy-${var.environment}"
  description = "Policy for Cluster Autoscaler"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeInstanceTypes"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach Policy to Cluster Autoscaler Role
resource "aws_iam_role_policy_attachment" "cluster_autoscaler_attachment" {
  count = var.install_cluster_autoscaler ? 1 : 0
  
  role       = aws_iam_role.cluster_autoscaler_role[0].name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy[0].arn
}

# Create Kubernetes Service Account for Cluster Autoscaler
resource "kubernetes_service_account" "cluster_autoscaler_sa" {
  count = var.install_cluster_autoscaler ? 1 : 0
  
  metadata {
    name      = local.cluster_autoscaler_sa_name
    namespace = local.kube_system_namespace
    
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler_role[0].arn
    }
    
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app"   = "cluster-autoscaler"
    }
  }
}

# Install Cluster Autoscaler via Helm
resource "helm_release" "cluster_autoscaler" {
  count = var.install_cluster_autoscaler ? 1 : 0
  
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = local.kube_system_namespace
  version    = var.cluster_autoscaler_chart_version
  
  set {
    name  = "rbac.serviceAccount.create"
    value = "false"
  }
  
  set {
    name  = "rbac.serviceAccount.name"
    value = local.cluster_autoscaler_sa_name
  }
  
  set {
    name  = "autoDiscovery.clusterName"
    value = var.eks_cluster_name
  }
  
  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }
  
  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }
  
  # Enable balancing of node groups
  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }
  
  # Enable skipping nodes with system pods
  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }
  
  # Resource settings
  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }
  
  set {
    name  = "resources.requests.memory"
    value = "128Mi"
  }
  
  set {
    name  = "resources.limits.cpu"
    value = "200m"
  }
  
  set {
    name  = "resources.limits.memory"
    value = "256Mi"
  }
  
  depends_on = [
    kubernetes_service_account.cluster_autoscaler_sa
  ]
}

# Install Metrics Server via Helm
resource "helm_release" "metrics_server" {
  count = var.install_metrics_server ? 1 : 0
  
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = local.kube_system_namespace
  version    = var.metrics_server_chart_version
  
  # Do not verify kubelet TLS certificates
  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }
  
  # Resource settings
  set {
    name  = "resources.requests.cpu"
    value = "20m"
  }
  
  set {
    name  = "resources.requests.memory"
    value = "64Mi"
  }
  
  set {
    name  = "resources.limits.cpu"
    value = "100m"
  }
  
  set {
    name  = "resources.limits.memory"
    value = "128Mi"
  }
}