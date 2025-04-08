# Monitoring module variables

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

variable "eks_oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "retention_in_days" {
  description = "Retention period for logs in days"
  type        = number
  default     = 30
}

variable "create_cloudwatch_dashboard" {
  description = "Create a CloudWatch dashboard for monitoring the EKS cluster"
  type        = bool
  default     = true
}

variable "create_cloudwatch_alarms" {
  description = "Create CloudWatch alarms for critical metrics"
  type        = bool
  default     = true
}

variable "cloudwatch_alarm_actions" {
  description = "List of ARNs for CloudWatch alarm actions (SNS, Lambda)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}