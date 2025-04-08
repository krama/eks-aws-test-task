# Variables for stage environment

environment = "stage"
region      = "eu-central-2"
prefix      = "eks"

# Network settings
vpc_cidr             = "10.20.0.0/16"
private_subnet_cidrs = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
public_subnet_cidrs  = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]
single_nat_gateway   = true  # Use single NAT gateway for stage to save money

# EKS cluster settings
eks_cluster_version    = "1.27"
endpoint_private_access = true
endpoint_public_access  = true
# Allow public access from internal IP addresses only
internal_access_cidrs  = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]

# Logging settings
cluster_log_types      = ["api", "audit", "authenticator", "controllerManager"]
log_retention_in_days  = 14  # Medium retention period for stage

# Node groups settings
node_groups_defaults = {
  ami_type       = "AL2_x86_64"
  instance_types = ["t3.medium"]  # Medium instances for stage
  disk_size      = 30
  min_size       = 1
  max_size       = 5
  desired_size   = 2  # Medium number of nodes for stage
}

managed_node_groups = {
  app_nodes = {
    name           = "app-nodes"
    instance_types = ["t3.medium"]
    min_size       = 2
    max_size       = 5
    desired_size   = 2
    disk_size      = 30
    labels = {
      role = "app"
    }
    taints = []
  }
  system_nodes = {
    name           = "system-nodes"
    instance_types = ["t3.small"]
    min_size       = 1
    max_size       = 3
    desired_size   = 1
    disk_size      = 20
    labels = {
      role = "system"
    }
    taints = [{
      key    = "dedicated"
      value  = "system"
      effect = "NO_SCHEDULE"
    }]
  }
}

# Additional components installation
aws_eks_addons = {
  vpc-cni = {
    addon_name        = "vpc-cni"
    addon_version     = "v1.13.2-eksbuild.1"
    resolve_conflicts = "OVERWRITE"
  }
  coredns = {
    addon_name        = "coredns"
    addon_version     = "v1.10.1-eksbuild.1"
    resolve_conflicts = "OVERWRITE"
  }
  kube-proxy = {
    addon_name        = "kube-proxy"
    addon_version     = "v1.27.1-eksbuild.1"
    resolve_conflicts = "OVERWRITE"
  }
}

# Installation of additional components
install_aws_load_balancer_controller = true
install_metrics_server = true
install_cluster_autoscaler = true
install_prometheus = true  # Install Prometheus for monitoring in stage
