variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  type        = string
}

variable "eks_cluster_version" {
  description = "Version of Kubernetes for the EKS cluster"
  type        = string
}

variable "eks_oidc_provider" {
  description = "URL of the EKS cluster's OIDC provider"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "ARN of the EKS cluster's OIDC provider"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC for the EKS cluster"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC for the EKS cluster"
  type        = string
}

variable "aws_eks_addons" {
  description = "Map of AWS EKS managed add-ons to install"
  type        = map(any)
  default     = {}
}

variable "install_cluster_autoscaler" {
  description = "Install Cluster Autoscaler for node auto-scaling"
  type        = bool
  default     = true
}

variable "cluster_autoscaler_chart_version" {
  description = "Version of the Cluster Autoscaler Helm chart"
  type        = string
  default     = "9.28.0"
}

variable "install_metrics_server" {
  description = "Install Metrics Server for HPA and VPA"
  type        = bool
  default     = true
}

variable "metrics_server_chart_version" {
  description = "Version of the Metrics Server Helm chart"
  type        = string
  default     = "3.10.0"
}

variable "install_aws_load_balancer_controller" {
  description = "Install AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "aws_load_balancer_controller_chart_version" {
  description = "Version of the AWS Load Balancer Controller Helm chart"
  type        = string
  default     = "1.5.3"
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}