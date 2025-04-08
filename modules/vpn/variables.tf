variable "prefix" {
  description = "Префикс для всех ресурсов"
  type        = string
}

variable "environment" {
  description = "Окружение развертывания"
  type        = string
}

variable "region" {
  description = "AWS регион"
  type        = string
}

variable "vpc_id" {
  description = "ID VPC для развертывания VPN"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR-блок VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "Список ID приватных подсетей для VPN"
  type        = list(string)
}

variable "eks_cluster_sg_id" {
  description = "ID группы безопасности кластера EKS"
  type        = string
}

variable "vpn_client_cidr" {
  description = "CIDR-блок для клиентов VPN"
  type        = string
  default     = "172.16.0.0/22"
}

variable "vpn_split_tunnel" {
  description = "Включить split tunnel для VPN (только трафик к VPC идет через VPN)"
  type        = bool
  default     = true
}

variable "vpn_enable_logs" {
  description = "Включить логирование подключений VPN"
  type        = bool
  default     = true
}

variable "vpn_log_retention_days" {
  description = "Период хранения логов VPN в днях"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Теги для всех ресурсов"
  type        = map(string)
  default     = {}
}