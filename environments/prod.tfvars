# Variables for production environment (prod)

environment = "prod"
region      = "eu-central-2"
prefix      = "eks"

# Network settings
vpc_cidr             = "10.40.0.0/16"
private_subnet_cidrs = ["10.40.1.0/24", "10.40.2.0/24", "10.40.3.0/24"]
public_subnet_cidrs  = ["10.40.101.0/24", "10.40.102.0/24", "10.40.103.0/24"]
single_nat_gateway   = false  # Use separate NAT gateway in each availability zone for maximum fault tolerance in Prod

# EKS cluster settings
eks_cluster_version    = "1.27"
endpoint_private_access = true
endpoint_public_access  = false  # Disable public access to API cluster in Prod
internal_access_cidrs  = []

# Logging settings
cluster_log_types      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
log_retention_in_days  = 90  # Long retention period for Prod

# Node groups settings
node_groups_defaults = {
  ami_type       = "AL2_x86_64"
  instance_types = ["m5.large"]
  disk_size      = 100
  min_size       = 3
  max_size       = 10
  desired_size   = 3
}

managed_node_groups = {
  app_nodes_a = {
    name           = "app-nodes-a"
    instance_types = ["m5.large"]
    capacity_type  = "ON_DEMAND"
    min_size       = 2
    max_size       = 10
    desired_size   = 3
    disk_size      = 100
    subnet_ids     = [] # Will be filled with the subnet of the first availability zone
    labels = {
      role = "app"
      az   = "a"
    }
    taints = []
  }
  app_nodes_b = {
    name           = "app-nodes-b"
    instance_types = ["m5.large"]
    capacity_type  = "ON_DEMAND"
    min_size       = 2
    max_size       = 10
    desired_size   = 3
    disk_size      = 100
    subnet_ids     = [] # Will be filled with the subnet of the second availability zone
    labels = {
      role = "app"
      az   = "b"
    }
    taints = []
  }
  app_nodes_c = {
    name           = "app-nodes-c"
    instance_types = ["m5.large"]
    capacity_type  = "ON_DEMAND"
    min_size       = 2
    max_size       = 10
    desired_size   = 3
    disk_size      = 100
    subnet_ids     = [] # Will be filled with the subnet of the third availability zone
    labels = {
      role = "app"
      az   = "c"
    }
    taints = []
  }
  system_nodes = {
    name           = "system-nodes"
    instance_types = ["m5.large"]
    capacity_type  = "ON_DEMAND"
    min_size       = 3
    max_size       = 6
    desired_size   = 3
    disk_size      = 50
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
    instance_types = ["m5.xlarge"]
    capacity_type  = "ON_DEMAND"
    min_size       = 2
    max_size       = 4
    desired_size   = 2
    disk_size      = 200  # Large size for storing metrics and logs
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
  aws-ebs-csi-driver = {
    addon_name        = "aws-ebs-csi-driver"
    addon_version     = "v1.20.0-eksbuild.1"
    resolve_conflicts = "OVERWRITE"
  }
}

# Additional components installation
install_aws_load_balancer_controller = true
install_metrics_server = true
install_cluster_autoscaler = true