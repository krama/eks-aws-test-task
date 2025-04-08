# EKS cluster module variables

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment for deployment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.27"
}

variable "vpc_id" {
  description = "ID of the VPC for the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of IDs of private subnets for EKS nodes"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Allow private access to the EKS cluster API server"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Allow public access to the EKS cluster API server"
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed for public access to the EKS cluster API server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_types" {
  description = "List of log types for the EKS cluster to send to CloudWatch"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_days" {
  description = "Number of days to retain EKS cluster logs in CloudWatch"
  type        = number
  default     = 30
}

variable "node_groups_defaults" {
  description = "Default settings for all EKS node groups"
  type        = any
  default     = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium"]
    disk_size      = 50
    min_size       = 1
    max_size       = 3
    desired_size   = 2
    labels         = {}
  }
}

variable "managed_node_groups" {
  description = "Map of configurations for EKS managed node groups"
  type        = any
  default     = {}
}

variable "fargate_profiles" {
  description = "Map of AWS Fargate profiles for running pods without EC2 instances"
  type        = any
  default     = {}
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth ConfigMap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}
