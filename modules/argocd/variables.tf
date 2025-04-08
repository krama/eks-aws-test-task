variable "prefix" {
  description = "Префикс для всех ресурсов"
  type        = string
}

variable "environment" {
  description = "Окружение развертывания"
  type        = string
}

variable "eks_cluster_name" {
  description = "Имя кластера EKS"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "ARN OIDC-провайдера кластера EKS"
  type        = string
}

variable "argocd_namespace" {
  description = "Kubernetes namespace для ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Версия Helm-чарта ArgoCD"
  type        = string
  default     = "5.46.0"
}

variable "argocd_admin_password_bcrypt" {
  description = "Bcrypt-хеш пароля администратора ArgoCD"
  type        = string
  sensitive   = true
  default     = "$2a$10$xPRRTG1CGWJf.CqAe3MFS.kVs8SYbpkB5Wn3QQidr1LvNUFm4r1MC" # Пароль по умолчанию: admin
}

variable "argocd_server_service_type" {
  description = "Тип сервиса для сервера ArgoCD (ClusterIP, LoadBalancer)"
  type        = string
  default     = "ClusterIP"
}

variable "argocd_server_url" {
  description = "URL сервера ArgoCD"
  type        = string
  default     = ""
}

variable "helm_charts_repository_url" {
  description = "URL Git-репозитория с Helm-чартами"
  type        = string
  default     = "https://github.com/your-org/helm-charts.git"
}

variable "tags" {
  description = "Теги для всех ресурсов"
  type        = map(string)
  default     = {}
}