# Configure providers for EKS infrastructure
provider "tls" {
  alias = "mocked"
}
provider "aws" {
  region = var.region

  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      apigateway     = var.localstack_endpoint
      appautoscaling = var.localstack_endpoint
      cloudformation = var.localstack_endpoint
      cloudwatch     = var.localstack_endpoint
      cloudwatchlogs = var.localstack_endpoint
      dynamodb       = var.localstack_endpoint
      ec2            = var.localstack_endpoint
      ecr            = var.localstack_endpoint
      ecs            = var.localstack_endpoint
      eks            = var.localstack_endpoint
      es             = var.localstack_endpoint
      firehose       = var.localstack_endpoint
      iam            = var.localstack_endpoint
      kinesis        = var.localstack_endpoint
      kms            = var.localstack_endpoint
      lambda         = var.localstack_endpoint
      redshift       = var.localstack_endpoint
      route53        = var.localstack_endpoint
      s3             = var.localstack_endpoint
      secretsmanager = var.localstack_endpoint
      ses            = var.localstack_endpoint
      sns            = var.localstack_endpoint
      sqs            = var.localstack_endpoint
      ssm            = var.localstack_endpoint
      stepfunctions  = var.localstack_endpoint
      sts            = var.localstack_endpoint
    }
  }

  access_key                  = var.use_localstack ? var.localstack_access_key : null
  secret_key                  = var.use_localstack ? var.localstack_secret_key : null
  skip_credentials_validation = var.use_localstack
  skip_requesting_account_id  = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  s3_use_path_style           = var.use_localstack

  default_tags {
    tags = local.common_tags
  }
}

# Kubernetes provider
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  # Используем стандартную конфигурацию для реального окружения
  dynamic "exec" {
    for_each = var.use_localstack ? [] : [1]
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }

  # Для LocalStack используем упрощенную конфигурацию 
  config_path = var.use_localstack ? "${path.module}/kubeconfig-localstack.yaml" : ""
}

# Helm provider for installing charts
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    dynamic "exec" {
      for_each = var.use_localstack ? [] : [1]
      content {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
      }
    }
    
    config_path = var.use_localstack ? "${path.module}/kubeconfig-localstack.yaml" : ""
  }
}

# Kubectl provider for applying manifests
provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = var.use_localstack

  dynamic "exec" {
    for_each = var.use_localstack ? [] : [1]
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
  
  config_path = var.use_localstack ? "${path.module}/kubeconfig-localstack.yaml" : ""
}