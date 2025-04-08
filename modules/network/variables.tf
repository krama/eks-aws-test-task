# Variables for network infrastructure module

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

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one for each AZ)"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one for each AZ)"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway instead of one per AZ"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for network traffic monitoring"
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "Retention period for VPC Flow Logs in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}