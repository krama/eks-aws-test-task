# Variables for development environment (dev)

environment = "dev"
region      = "eu-central-2"
prefix      = "eks"

# Network settings
vpc_cidr             = "10.10.0.0/16"
private_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
public_subnet_cidrs  = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]
single_nat_gateway   = true  # Use single NAT gateway for dev environment to save money

# EKS cluster settings
eks_cluster_version    = "1.27"
endpoint_private_access = true
endpoint_public_access  = true
# Allow public access from any IP for dev environment
internal_access_cidrs  = ["0.0.0.0/0"]

# Logging settings
cluster_log_types      = ["api", "audit", "authenticator"]  # Reduced set of logs for dev
log_retention_in_days  = 7  # Short retention period for dev

# Node groups settings
node_groups_defaults = {
  ami_type       = "AL2_x86_64"
  instance_types = ["t3.small"]  # Small instances for dev
  disk_size      = 20
  min_size       = 1
  max_size       = 3
  desired_size   = 1  # Minimum number of nodes for dev
}

# Additional components installation
install_aws_load_balancer_controller = true
install_metrics_server = true
install_cluster_autoscaler = true

managed_node_groups = {
  app_nodes = {
    name           = "app-nodes"
    instance_types = ["t3.small"]
    min_size       = 1
    max_size       = 3
    desired_size   = 1
    disk_size      = 20
    labels = {
      role = "app"
    }
    taints = []
  }
}

# Addons settings
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