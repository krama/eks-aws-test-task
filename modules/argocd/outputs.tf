output "argocd_namespace" {
  description = "Namespace, в котором установлен ArgoCD"
  value       = var.argocd_namespace
}

output "argocd_server_service_name" {
  description = "Имя сервиса сервера ArgoCD"
  value       = "argocd-server"
}

output "argocd_role_arn" {
  description = "ARN IAM-роли для ArgoCD"
  value       = aws_iam_role.argocd_role.arn
}

output "argocd_installed" {
  description = "Индикатор успешной установки ArgoCD"
  value       = helm_release.argocd.status == "deployed"
}

output "argocd_admin_password" {
  description = "Пароль администратора ArgoCD"
  value       = "admin" # По умолчанию, когда используется bcrypt-хеш
  sensitive   = true
}

output "argocd_config_file" {
  description = "Путь к файлу конфигурации ArgoCD"
  value       = local_file.argocd_config.filename
}