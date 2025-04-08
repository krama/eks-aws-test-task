# Output variables for monitoring module

output "prometheus_installed" {
  description = "Flag indicating if Prometheus was installed"
  value       = var.install_prometheus
}

output "prometheus_service_account_name" {
  description = "Name of Kubernetes service account for Prometheus"
  value       = var.install_prometheus ? local.prometheus_sa_name : null
}

output "prometheus_role_arn" {
  description = "ARN of IAM role for Prometheus"
  value       = var.install_prometheus ? aws_iam_role.prometheus_role[0].arn : null
}

output "monitoring_namespace" {
  description = "Name of Kubernetes namespace for monitoring"
  value       = local.monitoring_namespace
}

output "cluster_log_group_name" {
  description = "Name of CloudWatch Log Group for EKS cluster logs"
  value       = aws_cloudwatch_log_group.eks_cluster_logs.name
}

output "cluster_log_group_arn" {
  description = "ARN of CloudWatch Log Group for EKS cluster logs"
  value       = aws_cloudwatch_log_group.eks_cluster_logs.arn
}

output "cloudwatch_dashboard_name" {
  description = "Name of CloudWatch Dashboard for EKS cluster monitoring"
  value       = var.create_cloudwatch_dashboard ? aws_cloudwatch_dashboard.eks_dashboard[0].dashboard_name : null
}

output "cloudwatch_alarms" {
  description = "List of created CloudWatch Alarms for EKS cluster"
  value = var.create_cloudwatch_alarms ? {
    node_cpu_high = aws_cloudwatch_metric_alarm.node_cpu_high[0].id
    node_memory_high = aws_cloudwatch_metric_alarm.node_memory_high[0].id
    failed_nodes = aws_cloudwatch_metric_alarm.failed_nodes[0].id
  } : null
}
