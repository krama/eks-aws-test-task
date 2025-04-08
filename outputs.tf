# Project EKS output variables

output "vpc_id" {
  description = "ID of created VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of VPC"
  value       = module.network.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.network.public_subnet_ids
}

output "eks_cluster_name" {
  description = "Name of EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "API endpoint of EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "ID of security group created for EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "eks_managed_node_groups" {
  description = "Information about EKS managed node groups"
  value       = module.eks.managed_node_groups
}

output "eks_cluster_version" {
  description = "Kubernetes version of EKS cluster"
  value       = module.eks.cluster_version
}

output "eks_oidc_provider_arn" {
  description = "ARN of OIDC provider for EKS cluster"
  value       = module.eks.oidc_provider_arn
}

output "aws_load_balancer_controller_service_account" {
  description = "Name of service account for AWS Load Balancer Controller"
  value       = module.load_balancer.aws_load_balancer_controller_service_account_name
}

output "cluster_autoscaler_service_account" {
  description = "Name of service account for Cluster Autoscaler"
  value       = module.addons.cluster_autoscaler_service_account_name
}

output "metrics_server_installed" {
  description = "Metrics Server installation status"
  value       = module.addons.metrics_server_installed
}

# VPN outputs
output "vpn_endpoint_id" {
  description = "ID of VPN endpoint"
  value       = module.vpn.vpn_endpoint_id
}

output "vpn_dns_name" {
  description = "DNS name of VPN endpoint"
  value       = module.vpn.vpn_dns_name
}

# ArgoCD outputs
output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = var.install_argocd ? module.gitops[0].argocd_namespace : null
}

output "argocd_server_service_name" {
  description = "Name of ArgoCD server service"
  value       = var.install_argocd ? module.gitops[0].argocd_server_service_name : null
}

output "argocd_config_file" {
  description = "Path to ArgoCD configuration file"
  value       = var.install_argocd ? module.gitops[0].argocd_config_file : null
}