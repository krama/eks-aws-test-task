# Security module variables

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Security Groups"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
  default     = ""
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node groups"
  type        = any
  default     = {}
}

variable "eks_node_role_name" {
  description = "Name of the IAM role for EKS nodes"
  type        = string
  default     = ""
}

variable "attach_node_additional_policy" {
  description = "Attach additional policy to EKS node groups"
  type        = bool
  default     = true
}

variable "create_database_secrets" {
  description = "Create secrets for database credentials"
  type        = bool
  default     = true
}

variable "additional_security_groups" {
  description = "Additional Security Groups to add to EKS nodes"
  type        = list(string)
  default     = []
}

variable "allow_cluster_admin_roles" {
  description = "List of IAM role ARNs that are allowed to access the EKS cluster as admins"
  type        = list(string)
  default     = []
}

variable "allow_cluster_developer_roles" {
  description = "List of IAM role ARNs that are allowed to access the EKS cluster as developers"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-2"
}
