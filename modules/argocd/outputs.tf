output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = var.argocd_namespace
}

output "argocd_server_service_name" {
  description = "Name of ArgoCD server service"
  value       = "argocd-server"
}

output "argocd_role_arn" {
  description = "ARN of IAM role for ArgoCD"
  value       = aws_iam_role.argocd_role.arn
}

output "argocd_installed" {
  description = "Indicator for successful ArgoCD installation"
  value       = helm_release.argocd.status == "deployed"
}

output "argocd_admin_password" {
  description = "Admin password for ArgoCD"
  value       = "admin" # Default when using bcrypt hash
  sensitive   = true
}

output "argocd_config_file" {
  description = "Path to ArgoCD configuration file"
  value       = local_file.argocd_config.filename
}