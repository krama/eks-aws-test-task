# Variables for quality assurance environment (qa)

environment = "qa"
region      = "eu-central-2"
prefix      = "eks"

# Network settings
vpc_cidr             = "10.30.0.0/16"
private_subnet_cidrs = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
public_subnet_cidrs  = ["10.30.101.0/24", "10.30.102.0/24", "10.30.103.0/24"]
single_nat_gateway   = false  # Use multiple NAT gateways for fault tolerance in QA

# EKS cluster settings
eks_cluster_version    = "1.27"
endpoint_private_access = true
endpoint_public_access  = true
# Allow public access from internal IP addresses only
internal_access_cidrs  = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]

# Logging settings
cluster_log_types      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
log_retention_in_days  = 30  # Longer retention period for QA

# Node groups settings
node_groups_defaults = {
  ami_type       = "AL2_x86_64"
  instance_types = ["t3.medium"]
  disk_size      = 50
  min_size       = 2
  max_size       = 8
  desired_size   = 3
}

managed_node_groups = {
  app_nodes = {
    name           = "app-nodes"
    instance_types = ["t3.medium", "t3.large"]  # Multiple instance types for spot instances and cost savings
    capacity_type  = "SPOT"  # Use spot instances for cost savings in QA
    min_size       = 2
    max_size       = 8
    desired_size   = 3
    disk_size      = 50
    labels = {
      role = "app"
    }
    taints = []
  }
  system_nodes = {
    name           = "system-nodes"
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"  # Critical components on on-demand instances
    min_size       = 2
    max_size       = 4
    desired_size   = 2
    disk_size      = 30
    labels = {
      role = "system"
    }
    taints = [{
      key    = "dedicated"
      value  = "system"
      effect = "NO_SCHEDULE"
    }]
  }
  monitoring_nodes = {
    name           = "monitoring-nodes"
    instance_types = ["t3.large"]
    capacity_type  = "ON_DEMAND"
    min_size       = 1
    max_size       = 2
    desired_size   = 1
    disk_size      = 100  # More space for metrics and logs
    labels = {
      role = "monitoring"
    }
    taints = [{
      key    = "dedicated"
      value  = "monitoring"
      effect = "NO_SCHEDULE"
    }]
  }
}

# Additional components installation
install_aws_load_balancer_controller = true
install_metrics_server = true
install_cluster_autoscaler = true