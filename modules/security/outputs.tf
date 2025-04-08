# Output variables for security module

output "pods_aws_services_sg_id" {
  description = "ID of security group for pods that require access to AWS services"
  value       = aws_security_group.pods_aws_services_sg.id
}

output "pods_communication_sg_id" {
  description = "ID of security group for communication between pods"
  value       = aws_security_group.pods_communication_sg.id
}

output "database_sg_id" {
  description = "ID of security group for databases"
  value       = aws_security_group.database_sg.id
}

output "s3_access_role_arn" {
  description = "ARN of IAM role for S3 access"
  value       = aws_iam_role.s3_access_role.arn
}

output "s3_access_role_name" {
  description = "Name of IAM role for S3 access"
  value       = aws_iam_role.s3_access_role.name
}

output "sqs_access_role_arn" {
  description = "ARN of IAM role for SQS access"
  value       = aws_iam_role.sqs_access_role.arn
}

output "sqs_access_role_name" {
  description = "Name of IAM role for SQS access"
  value       = aws_iam_role.sqs_access_role.name
}

output "eks_node_additional_policy_arn" {
  description = "ARN of additional IAM policy for EKS nodes"
  value       = aws_iam_policy.eks_node_additional_policy.arn
}

output "eks_node_additional_policy_name" {
  description = "Name of additional IAM policy for EKS nodes"
  value       = aws_iam_policy.eks_node_additional_policy.name
}

output "kms_secrets_key_arn" {
  description = "ARN of KMS key for EKS secrets encryption"
  value       = aws_kms_key.eks_secrets_key.arn
}

output "kms_secrets_key_id" {
  description = "ID of KMS key for EKS secrets encryption"
  value       = aws_kms_key.eks_secrets_key.key_id
}

output "database_credentials_secret_arn" {
  description = "ARN of secret for database credentials"
  value       = var.create_database_secrets ? aws_secretsmanager_secret.database_credentials[0].arn : null
}

output "database_credentials_secret_name" {
  description = "Name of secret for database credentials"
  value       = var.create_database_secrets ? aws_secretsmanager_secret.database_credentials[0].name : null
}