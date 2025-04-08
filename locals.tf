# Local variables for EKS project

locals {
  # Common tags for all resources
  common_tags = {
    Project     = "EKS-Platform"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "DevOps"
  }

  # Merge common tags with additional ones
  resource_tags = merge(local.common_tags, var.tags)
  
  # Full resource prefix with environment
  resource_prefix = "${var.prefix}-${var.environment}"
  
  # EKS cluster name
  eks_cluster_name = "${local.resource_prefix}-eks-cluster"

  aws_lb_controller_sa_name  = "aws-load-balancer-controller"
  
  # Mapping of environments to log levels
  environment_log_level = {
    "dev"     = "INFO"
    "stage"   = "INFO"
    "qa"      = "INFO" 
    "prod"    = "WARNING"
  }
  
  # Calculate current log level based on environment
  current_log_level = lookup(local.environment_log_level, var.environment, "INFO")
  
  # Mapping of security params to environments
  security_params = {
    dev = {
      endpoint_public_access  = true
      endpoint_private_access = true
      public_access_cidrs     = ["0.0.0.0/0"]
      allow_debug_tools       = true
    }
    stage = {
      endpoint_public_access  = true
      endpoint_private_access = true
      public_access_cidrs     = ["0.0.0.0/0"]
      allow_debug_tools       = true
    }
    qa = {
      endpoint_public_access  = true
      endpoint_private_access = true
      public_access_cidrs     = var.internal_access_cidrs
      allow_debug_tools       = true
    }
    prod = {
      endpoint_public_access  = false
      endpoint_private_access = true
      public_access_cidrs     = []
      allow_debug_tools       = false
    }
  }
}