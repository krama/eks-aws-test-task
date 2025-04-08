# Output variables for Load Balancer module

output "aws_load_balancer_controller_role_arn" {
  description = "ARN of IAM role for AWS Load Balancer Controller"
  value       = aws_iam_role.aws_lb_controller_role.arn
}

output "aws_load_balancer_controller_role_name" {
  description = "Name of IAM role for AWS Load Balancer Controller"
  value       = aws_iam_role.aws_lb_controller_role.name
}

output "aws_load_balancer_controller_policy_arn" {
  description = "ARN of IAM policy for AWS Load Balancer Controller"
  value       = aws_iam_policy.aws_lb_controller_policy.arn
}

output "aws_load_balancer_controller_policy_name" {
  description = "Name of IAM policy for AWS Load Balancer Controller"
  value       = aws_iam_policy.aws_lb_controller_policy.name
}

output "aws_load_balancer_controller_service_account_name" {
  description = "Name of Kubernetes service account for AWS Load Balancer Controller"
  value       = local.aws_lb_controller_sa_name
}

output "aws_load_balancer_controller_namespace" {
  description = "Kubernetes namespace for AWS Load Balancer Controller"
  value       = local.aws_lb_controller_namespace
}

output "alb_security_group_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

output "aws_load_balancer_controller_installed" {
  description = "Flag indicating if AWS Load Balancer Controller was installed"
  value       = var.install_aws_load_balancer_controller
}
