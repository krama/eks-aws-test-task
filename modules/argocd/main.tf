# GitOps Module for ArgoCD installation

# Retrieve current AWS account data
data "aws_caller_identity" "current" {}

# Current AWS region data
data "aws_region" "current" {}

# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    
    labels = {
      name = var.argocd_namespace
    }
  }
}

# Create IAM role for ArgoCD
resource "aws_iam_role" "argocd_role" {
  name = "${var.prefix}-argocd-role-${var.environment}"
  
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
          "${replace(var.eks_oidc_provider_arn, "/^(.+)\\/(.+)$/", "$2")}:sub": "system:serviceaccount:${var.argocd_namespace}:argocd-application-controller"
        }
      }
    }]
  })
}

# Policy for accessing AWS services from ArgoCD
resource "aws_iam_policy" "argocd_policy" {
  name        = "${var.prefix}-argocd-policy-${var.environment}"
  description = "Policy for ArgoCD"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "s3:GetObject",
          "s3:ListBucket",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "argocd_policy_attachment" {
  role       = aws_iam_role.argocd_role.name
  policy_arn = aws_iam_policy.argocd_policy.arn
}

# Create Kubernetes service account for ArgoCD
resource "kubernetes_service_account" "argocd_controller_sa" {
  metadata {
    name      = "argocd-application-controller"
    namespace = var.argocd_namespace
    
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.argocd_role.arn
    }
  }
  
  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# Install ArgoCD via Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = var.argocd_namespace
  version    = var.argocd_chart_version
  
  set {
    name  = "server.service.type"
    value = var.argocd_server_service_type
  }
  
  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }
  
  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }
  
  set {
    name  = "controller.serviceAccount.name"
    value = "argocd-application-controller"
  }
  
  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.argocd_admin_password_bcrypt
  }
  
  set {
    name  = "configs.repositories.private-repo.url"
    value = var.helm_charts_repository_url
  }
  
  set {
    name  = "configs.repositories.private-repo.insecure"
    value = "true"
  }
  
  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_service_account.argocd_controller_sa
  ]
}

# Generate configuration file for ArgoCD clients
resource "local_file" "argocd_config" {
  content  = <<-EOF
apiVersion: v1
kind: Config
clusters:
- name: ${var.eks_cluster_name}
  cluster:
    server: https://${var.argocd_server_url}
    insecure-skip-tls-verify: true
contexts:
- name: ${var.eks_cluster_name}
  context:
    cluster: ${var.eks_cluster_name}
    user: admin
current-context: ${var.eks_cluster_name}
users:
- name: admin
  user:
    username: admin
    password: admin
EOF
  filename = "${path.module}/argocd-config.yaml"
}