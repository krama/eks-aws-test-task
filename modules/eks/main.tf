# EKS Cluster Module

# Retrieve current AWS account information
data "aws_caller_identity" "current" {}

# Get current AWS region data
data "aws_region" "current" {}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.prefix}-eks-cluster-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# Attach AmazonEKSClusterPolicy to EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Attach AmazonEKSVPCResourceController policy to EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# Create security group for EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.prefix}-eks-cluster-sg-${var.environment}"
  description = "Security group for EKS control plane"
  vpc_id      = var.vpc_id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-eks-cluster-sg-${var.environment}"
    }
  )
}

# Allow outbound traffic from EKS cluster
resource "aws_security_group_rule" "eks_cluster_egress" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

# Create security group for EKS nodes
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.prefix}-eks-node-sg-${var.environment}"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-eks-node-sg-${var.environment}",
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

# Allow all traffic between nodes
resource "aws_security_group_rule" "eks_nodes_internal" {
  security_group_id        = aws_security_group.eks_nodes_sg.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  description              = "Allow node to node all traffic"
}

# Allow outbound traffic from nodes
resource "aws_security_group_rule" "eks_nodes_egress" {
  security_group_id = aws_security_group.eks_nodes_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

# Allow all traffic from cluster to nodes
resource "aws_security_group_rule" "eks_cluster_to_node" {
  security_group_id        = aws_security_group.eks_nodes_sg.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  description              = "Allow all traffic from control plane to nodes"
}

# Allow all traffic from nodes to cluster
resource "aws_security_group_rule" "eks_node_to_cluster" {
  security_group_id        = aws_security_group.eks_cluster_sg.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  description              = "Allow all traffic from nodes to control plane"
}

# Create EKS cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.cluster_version
  
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }
  
  enabled_cluster_log_types = var.cluster_log_types
  
  # Encrypt secrets using KMS
  encryption_config {
    resources = ["secrets"]
    
    provider {
      key_arn = aws_kms_key.eks_encryption_key.arn
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
    aws_cloudwatch_log_group.eks_cluster_logs
  ]
}

# Create KMS key for EKS secrets encryption
resource "aws_kms_key" "eks_encryption_key" {
  description             = "KMS key for EKS cluster secrets encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-eks-encryption-key-${var.environment}"
    }
  )
}

# Create alias for KMS key
resource "aws_kms_alias" "eks_encryption_key_alias" {
  name          = "alias/${var.prefix}-eks-encryption-key-${var.environment}"
  target_key_id = aws_kms_key.eks_encryption_key.key_id
}

# Create CloudWatch log group for EKS cluster
resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-eks-cluster-logs-${var.environment}"
    }
  )
}

# Create IAM role for EKS node groups
resource "aws_iam_role" "eks_node_role" {
  name = "${var.prefix}-eks-node-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach necessary policies to EKS node role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_node_role.name
}

# Create OIDC provider for EKS cluster
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-eks-oidc-provider-${var.environment}"
    }
  )
}

# Create managed node groups for EKS
resource "aws_eks_node_group" "eks_node_groups" {
  for_each = var.managed_node_groups
  
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.prefix}-${each.value.name}-${var.environment}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  
  # Use specified subnets or all private subnets
  subnet_ids = length(lookup(each.value, "subnet_ids", [])) > 0 ? each.value.subnet_ids : var.private_subnet_ids
  
  instance_types = lookup(each.value, "instance_types", var.node_groups_defaults.instance_types)
  ami_type       = lookup(each.value, "ami_type", var.node_groups_defaults.ami_type)
  capacity_type  = lookup(each.value, "capacity_type", "ON_DEMAND")
  disk_size      = lookup(each.value, "disk_size", var.node_groups_defaults.disk_size)
  
  scaling_config {
    desired_size = lookup(each.value, "desired_size", var.node_groups_defaults.desired_size)
    min_size     = lookup(each.value, "min_size", var.node_groups_defaults.min_size)
    max_size     = lookup(each.value, "max_size", var.node_groups_defaults.max_size)
  }
  
  update_config {
    max_unavailable = lookup(each.value, "max_unavailable", 1)
  }
  
  # Kubernetes labels for nodes
  dynamic "taint" {
    for_each = lookup(each.value, "taints", [])
    content {
      key    = taint.value.key
      value  = lookup(taint.value, "value", null)
      effect = taint.value.effect
    }
  }
  
  labels = merge(
    var.node_groups_defaults.labels,
    lookup(each.value, "labels", {})
  )
  
  # Use Launch Template for additional settings if specified
  dynamic "launch_template" {
    for_each = lookup(each.value, "launch_template_id", null) != null ? [1] : []
    
    content {
      id      = each.value.launch_template_id
      version = lookup(each.value, "launch_template_version", "$Latest")
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-${each.value.name}-${var.environment}"
    },
    lookup(each.value, "tags", {})
  )
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_readonly,
    aws_iam_role_policy_attachment.eks_ssm_policy
  ]
  
  # Set rollout period for updates
  timeouts {
    create = "30m"
    update = "45m"
    delete = "30m"
  }

  # Required lifecycle to prevent issues during updates
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
