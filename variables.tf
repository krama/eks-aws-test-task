# Main variables for EKS infrastructure

# General settings
variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-central-2"
}

variable "environment" {
  description = "Environment for deployment (dev, stage, qa, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "stage", "qa", "prod"], var.environment)
    error_message = "The value of environment must be one of: dev, stage, qa, prod."
  }
}

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "eks"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

# Network settings
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one for each AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one for each AZ)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "single_nat_gateway" {
  description = "Use single NAT gateway for all private subnets"
  type        = bool
  default     = false
}

variable "internal_access_cidrs" {
  description = "CIDR blocks for internal access to the cluster"
  type        = list(string)
  default     = []
}

# EKS cluster settings
variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.31"
}

variable "endpoint_private_access" {
  description = "Enable private endpoint access to the cluster"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public endpoint access to the cluster"
  type        = bool
  default     = false
}

variable "cluster_log_types" {
  description = "List of log types to send to CloudWatch"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_in_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 30
}

# EKS node group settings
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
  description = "Configuration for managed node groups"
  type        = any
  default     = {
    app_nodes_a = {
      name           = "app-nodes-a"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 5
      desired_size   = 2
      disk_size      = 50
      # Привязка к первой зоне доступности
      subnet_ids     = [] # Будет заполнено автоматически
      labels = {
        role = "app"
        az   = "a"
      }
      taints = []
    }
    app_nodes_b = {
      name           = "app-nodes-b"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 5
      desired_size   = 2
      disk_size      = 50
      # Привязка ко второй зоне доступности
      subnet_ids     = [] # Будет заполнено автоматически
      labels = {
        role = "app"
        az   = "b"
      }
      taints = []
    }
  }
}

# EKS add-ons settings
variable "aws_eks_addons" {
  description = "List of managed add-ons for EKS"
  type        = map(any)
  default     = {
    vpc-cni = {
      addon_name               = "vpc-cni"
      addon_version            = "v1.13.2-eksbuild.1"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = null
    }
    coredns = {
      addon_name               = "coredns"
      addon_version            = "v1.10.1-eksbuild.1"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = null
    }
    kube-proxy = {
      addon_name               = "kube-proxy"
      addon_version            = "v1.27.1-eksbuild.1"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = null
    }
  }
}

variable "install_aws_load_balancer_controller" {
  description = "Install AWS Load Balancer Controller for ALB/NLB management"
  type        = bool
  default     = true
}

variable "install_metrics_server" {
  description = "Install Metrics Server for HPA and VPA"
  type        = bool
  default     = true
}

variable "install_cluster_autoscaler" {
  description = "Install Cluster Autoscaler for automatic node scaling"
  type        = bool
  default     = true
}

# LocalStack settings
variable "use_localstack" {
  description = "Use LocalStack for local development"
  type        = bool
  default     = true
}

variable "localstack_endpoint" {
  description = "LocalStack endpoint URL"
  type        = string
  default     = "http://localhost:4566"
}

variable "localstack_access_key" {
  description = "LocalStack access key"
  type        = string
  default     = "test"
  sensitive   = true
}

variable "localstack_secret_key" {
  description = "LocalStack secret key"
  type        = string
  default     = "test"
  sensitive   = true
}

# VPN settings
variable "vpn_client_cidr" {
  description = "CIDR block for VPN clients"
  type        = string
  default     = "172.16.0.0/22"
}

variable "vpn_split_tunnel" {
  description = "Enable split tunnel for VPN"
  type        = bool
  default     = true
}

variable "vpn_enable_logs" {
  description = "Enable logging for VPN connections"
  type        = bool
  default     = true
}
