# Output variables for monitoring module
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