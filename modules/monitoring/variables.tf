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

variable "create_monitoring_namespace" {
  description = "Create a namespace for monitoring in Kubernetes"
  type        = bool
  default     = true
}

variable "install_prometheus" {
  description = "Install Prometheus for monitoring"
  type        = bool
  default     = true
}

variable "prometheus_chart_version" {
  description = "Version of the Prometheus Helm chart"
  type        = string
  default     = "22.6.2"
}

variable "prometheus_persistent_storage" {
  description = "Enable persistent storage for Prometheus"
  type        = bool
  default     = true
}

variable "prometheus_storage_size" {
  description = "Size of the persistent storage for Prometheus"
  type        = string
  default     = "20Gi"
}

variable "prometheus_cpu_request" {
  description = "CPU request for Prometheus"
  type        = string
  default     = "200m"
}

variable "prometheus_memory_request" {
  description = "Memory request for Prometheus"
  type        = string
  default     = "512Mi"
}

variable "prometheus_cpu_limit" {
  description = "CPU limit for Prometheus"
  type        = string
  default     = "1000m"
}

variable "prometheus_memory_limit" {
  description = "Memory limit for Prometheus"
  type        = string
  default     = "2Gi"
}

variable "prometheus_retention_period" {
  description = "Retention period for metrics in Prometheus"
  type        = string
  default     = "15d"
}

variable "prometheus_service_type" {
  description = "Type of the Kubernetes service for Prometheus (ClusterIP, LoadBalancer)"
  type        = string
  default     = "ClusterIP"
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
