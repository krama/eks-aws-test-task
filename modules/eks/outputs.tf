# Output variables for EKS cluster module

output "cluster_id" {
  description = "ID of EKS cluster"
  value       = aws_eks_cluster.eks_cluster.id
}

output "cluster_name" {
  description = "Name of EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_arn" {
  description = "ARN of EKS cluster"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS cluster API server"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_version" {
  description = "Kubernetes version of EKS cluster"
  value       = aws_eks_cluster.eks_cluster.version
}

output "cluster_security_group_id" {
  description = "ID of EKS cluster security group"
  value       = aws_security_group.eks_cluster_sg.id
}

output "node_security_group_id" {
  description = "ID of EKS nodes security group"
  value       = aws_security_group.eks_nodes_sg.id
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data in base64"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "managed_node_groups" {
  description = "Information about EKS managed node groups"
  value       = aws_eks_node_group.eks_node_groups
}

output "oidc_provider" {
  description = "URL of EKS cluster OIDC provider"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of EKS cluster OIDC provider"
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "cluster_primary_security_group_id" {
  description = "ID of primary EKS cluster security group, created automatically"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "node_role_arn" {
  description = "ARN of EKS node IAM role"
  value       = aws_iam_role.eks_node_role.arn
}

output "node_role_name" {
  description = "Name of EKS node IAM role"
  value       = aws_iam_role.eks_node_role.name
}

output "encryption_key_arn" {
  description = "ARN of KMS key for EKS secrets encryption"
  value       = aws_kms_key.eks_encryption_key.arn
}

output "cluster_log_group_name" {
  description = "Name of CloudWatch Logs group for EKS cluster logs"
  value       = aws_cloudwatch_log_group.eks_cluster_logs.name
}
