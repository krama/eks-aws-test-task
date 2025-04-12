# Main file of the EKS project, integrates all modules into a single infrastructure

# Network infrastructure module
module "network" {
  source = "./modules/network"

  prefix               = var.prefix
  environment          = var.environment
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  tags                 = local.resource_tags
}

# Security module (IAM, Security Groups, etc.)
module "security" {
  source              = "./modules/security"
  prefix              = var.prefix
  environment         = var.environment
  region              = var.region
  vpc_id              = module.network.vpc_id
  cluster_name        = local.eks_cluster_name
  oidc_provider_arn   = module.eks.oidc_provider_arn
  eks_managed_node_groups = module.eks.managed_node_groups
  tags                = local.resource_tags

  eks_node_role_name  = module.eks.node_role_name

  depends_on = [module.network, module.eks]
}

# EKS cluster module
module "eks" {
  source = "./modules/eks"

  prefix                   = var.prefix
  environment              = var.environment
  region                   = var.region
  vpc_id                   = module.network.vpc_id
  private_subnet_ids       = module.network.private_subnet_ids
  cluster_name             = local.eks_cluster_name
  cluster_version          = var.eks_cluster_version
  endpoint_private_access  = var.endpoint_private_access 
  endpoint_public_access   = var.endpoint_public_access
  cluster_log_types        = var.cluster_log_types
  
  # Node groups settings
  node_groups_defaults     = var.node_groups_defaults
  managed_node_groups      = var.managed_node_groups
  
  # Флаг использования LocalStack
  use_localstack           = var.use_localstack
  
  tags                     = local.resource_tags

  depends_on = [module.network]
}

# Load Balancer (ALB) module
module "load_balancer" {
  source = "./modules/load-balancer"

  prefix                   = var.prefix
  environment              = var.environment
  vpc_id                   = module.network.vpc_id
  public_subnet_ids        = module.network.public_subnet_ids
  eks_cluster_name         = module.eks.cluster_name
  oidc_provider_arn        = module.eks.oidc_provider_arn
  use_localstack           = var.use_localstack
  tags                     = local.resource_tags

  depends_on = [module.eks, module.security]
}

# EKS Add-ons module
module "addons" {
  source = "./modules/addons"

  prefix                   = var.prefix
  environment              = var.environment
  eks_cluster_name         = module.eks.cluster_name
  eks_cluster_endpoint     = module.eks.cluster_endpoint
  eks_cluster_version      = module.eks.cluster_version
  eks_oidc_provider        = module.eks.oidc_provider
  eks_oidc_provider_arn    = module.eks.oidc_provider_arn
  vpc_id                   = module.network.vpc_id
  vpc_cidr                 = module.network.vpc_cidr_block

  # List of EKS add-ons
  aws_eks_addons           = var.aws_eks_addons
  install_aws_load_balancer_controller = var.install_aws_load_balancer_controller
  install_metrics_server    = var.install_metrics_server
  install_cluster_autoscaler = var.install_cluster_autoscaler
  
  # Флаг использования LocalStack
  use_localstack           = var.use_localstack
  
  tags                     = local.resource_tags

  depends_on = [module.eks, module.security]
}

# Monitoring module (CloudWatch)
module "monitoring" {
  source = "./modules/monitoring"

  prefix               = var.prefix
  environment          = var.environment
  eks_cluster_name     = module.eks.cluster_name
  retention_in_days    = var.log_retention_in_days
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  tags                 = local.resource_tags

  depends_on = [module.eks, module.addons]
}

# VPN module
module "vpn" {
  source = "./modules/vpn"

  prefix               = var.prefix
  environment          = var.environment
  region               = var.region
  vpc_id               = module.network.vpc_id
  vpc_cidr             = module.network.vpc_cidr_block
  private_subnet_ids   = module.network.private_subnet_ids
  eks_cluster_sg_id    = module.eks.cluster_security_group_id
  vpn_client_cidr      = var.vpn_client_cidr
  vpn_split_tunnel     = var.vpn_split_tunnel
  vpn_enable_logs      = var.vpn_enable_logs
  use_localstack       = var.use_localstack
  tags                 = local.resource_tags

  depends_on = [module.network, module.eks]
}

# ArgoCD module
module "gitops" {
  count  = var.install_argocd && !var.use_localstack ? 1 : 0
  source = "./modules/argocd"

  prefix               = var.prefix
  environment          = var.environment
  eks_cluster_name     = module.eks.cluster_name
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  argocd_server_url    = module.eks.cluster_endpoint
  helm_charts_repository_url = var.helm_charts_repository_url
  tags                 = local.resource_tags

  depends_on = [module.eks, module.security]
}