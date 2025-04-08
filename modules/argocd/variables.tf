variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of EKS cluster"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "ARN of OIDC provider for EKS cluster"
  type        = string
}

variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Helm chart version for ArgoCD"
  type        = string
  default     = "5.46.0"
}

variable "argocd_admin_password_bcrypt" {
  description = "Bcrypt hash of admin password for ArgoCD"
  type        = string
  sensitive   = true
  default     = "$2a$10$xPRRTG1CGWJf.CqAe3MFS.kVs8SYbpkB5Wn3QQidr1LvNUFm4r1MC" # Default password: admin
}

variable "argocd_server_service_type" {
  description = "Service type for ArgoCD server (ClusterIP, LoadBalancer)"
  type        = string
  default     = "ClusterIP"
}

variable "argocd_server_url" {
  description = "URL of ArgoCD server"
  type        = string
  default     = ""
}

variable "helm_charts_repository_url" {
  description = "URL of Git repository with Helm charts"
  type        = string
  default     = "https://github.com/your-org/helm-charts.git"
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}