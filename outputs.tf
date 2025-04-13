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

# Kubeconfig output
output "kubeconfig" {
  description = "Kubeconfig for accessing the EKS cluster"
  value       = <<-EOT
apiVersion: v1
kind: Config
clusters:
- name: ${module.eks.cluster_name}
  cluster:
    server: ${module.eks.cluster_endpoint}
    certificate-authority-data: ${module.eks.cluster_certificate_authority_data}
contexts:
- name: ${module.eks.cluster_name}
  context:
    cluster: ${module.eks.cluster_name}
    user: ${module.eks.cluster_name}
current-context: ${module.eks.cluster_name}
users:
- name: ${module.eks.cluster_name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${module.eks.cluster_name}"
        - "--region"
        - "${var.region}"
EOT
  sensitive   = true
}