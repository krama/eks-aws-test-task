# GitOps Module for ArgoCD installation

# Получаем данные о текущем AWS аккаунте
data "aws_caller_identity" "current" {}

# Данные о текущем AWS регионе
data "aws_region" "current" {}

# Создаем пространство имен для ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    
    labels = {
      name = var.argocd_namespace
    }
  }
}

# Создаем IAM-роль для ArgoCD
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

# Политика для доступа к AWS-сервисам из ArgoCD
resource "aws_iam_policy" "argocd_policy" {
  name        = "${var.prefix}-argocd-policy-${var.environment}"
  description = "Политика для ArgoCD"
  
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

# Привязываем политику к роли
resource "aws_iam_role_policy_attachment" "argocd_policy_attachment" {
  role       = aws_iam_role.argocd_role.name
  policy_arn = aws_iam_policy.argocd_policy.arn
}

# Создаем сервисный аккаунт Kubernetes для ArgoCD
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

# Устанавливаем ArgoCD через Helm
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

# Генерируем файл конфигурации для клиентов ArgoCD
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