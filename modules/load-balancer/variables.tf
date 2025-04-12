# Load Balancer module variables

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for ALB deployment"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "create_service_account" {
  description = "Create a service account for the AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "install_aws_load_balancer_controller" {
  description = "Install the AWS Load Balancer Controller using Helm"
  type        = bool
  default     = true
}

variable "aws_load_balancer_controller_chart_version" {
  description = "Version of the Helm chart for the AWS Load Balancer Controller"
  type        = string
  default     = "1.5.3"
}

variable "controller_cpu_request" {
  description = "CPU request for the controller"
  type        = string
  default     = "100m"
}

variable "controller_memory_request" {
  description = "Memory request for the controller"
  type        = string
  default     = "128Mi"
}

variable "controller_cpu_limit" {
  description = "CPU limit for the controller"
  type        = string
  default     = "500m"
}

variable "controller_memory_limit" {
  description = "Memory limit for the controller"
  type        = string
  default     = "512Mi"
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}

variable "use_localstack" {
  description = "Flag indicating if LocalStack is being used"
  type        = bool
  default     = false
}