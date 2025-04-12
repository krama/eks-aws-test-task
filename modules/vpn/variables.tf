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
  description = "ID of VPC for VPN deployment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for VPN"
  type        = list(string)
}

variable "eks_cluster_sg_id" {
  description = "ID of EKS cluster security group"
  type        = string
}

variable "vpn_client_cidr" {
  description = "CIDR block for VPN clients"
  type        = string
  default     = "172.16.0.0/22"
}

variable "vpn_split_tunnel" {
  description = "Enable split tunnel for VPN (only traffic to VPC goes through VPN)"
  type        = bool
  default     = true
}

variable "vpn_enable_logs" {
  description = "Enable logging for VPN connections"
  type        = bool
  default     = true
}

variable "vpn_log_retention_days" {
  description = "Retention period for VPN logs in days"
  type        = number
  default     = 30
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