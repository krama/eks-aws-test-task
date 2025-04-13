variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC for EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS nodes"
  type        = list(string)
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "availability_zones" {
  description = "List of availability zones used by subnets"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.31"
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint for EKS"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint for EKS"
  type        = bool
  default     = false
}

variable "cluster_log_types" {
  description = "List of log types to send to CloudWatch"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_days" {
  description = "Number of days to retain EKS logs in CloudWatch"
  type        = number
  default     = 30
}

variable "node_groups_defaults" {
  description = "Default settings for EKS node groups"
  type        = any
  default     = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium"]
    disk_size      = 50
    min_size       = 1
    max_size       = 3
    desired_size   = 1
  }
}

variable "managed_node_groups" {
  description = "Map of managed node group configurations"
  type        = any
  default     = {}
}

variable "cluster_security_group_additional_rules" {
  description = "Additional security group rules for EKS cluster"
  type        = any
  default     = {}
}

variable "node_security_group_additional_rules" {
  description = "Additional security group rules for EKS nodes"
  type        = any
  default     = {}
}

variable "aws_auth_users" {
  description = "List of IAM users to add to the aws-auth ConfigMap"
  type        = list(any)
  default     = []
}

variable "aws_auth_roles" {
  description = "List of IAM roles to add to the aws-auth ConfigMap"
  type        = list(any)
  default     = []
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
