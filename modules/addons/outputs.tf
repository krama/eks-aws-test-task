# Output variables of the module

output "aws_eks_addons" {
  description = "Information about installed AWS EKS managed add-ons"
  value       = aws_eks_addon.eks_addons
}

output "cluster_autoscaler_installed" {
  description = "Flag indicating if Cluster Autoscaler was installed"
  value       = var.install_cluster_autoscaler
}

output "cluster_autoscaler_service_account_name" {
  description = "Name of the Kubernetes service account for Cluster Autoscaler"
  value       = var.install_cluster_autoscaler ? local.cluster_autoscaler_sa_name : null
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of the IAM role for Cluster Autoscaler"
  value       = var.install_cluster_autoscaler ? aws_iam_role.cluster_autoscaler_role[0].arn : null
}

output "metrics_server_installed" {
  description = "Flag indicating if Metrics Server was installed"
  value       = var.install_metrics_server
}

output "metrics_server_version" {
  description = "Version of installed Metrics Server"
  value       = var.install_metrics_server ? var.metrics_server_chart_version : null
}
