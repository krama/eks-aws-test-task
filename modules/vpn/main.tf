# VPN Module for access to EKS cluster

# Retrieve current AWS account data
data "aws_caller_identity" "current" {}

# Current AWS region data
data "aws_region" "current" {}

# Create client certificate (self-signed for example)
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = "eks-vpn-ca.internal"
    organization = "EKS VPN CA"
  }

  validity_period_hours = 87600
  is_ca_certificate     = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name  = "eks-vpn-server.internal"
    organization = "EKS VPN Server"
  }
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Upload certificates to ACM
resource "aws_acm_certificate" "server" {
  count = var.use_localstack ? 0 : 1
  
  private_key       = tls_private_key.server.private_key_pem
  certificate_body  = tls_locally_signed_cert.server.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem
}

# Создаем mock-ресурс для LocalStack
resource "null_resource" "acm_mock" {
  count = var.use_localstack ? 1 : 0
  
  # Симуляция ACM сертификата для LocalStack
  triggers = {
    certificate_arn = "arn:aws:acm:${var.region}:${data.aws_caller_identity.current.account_id}:certificate/mock-certificate-id"
  }
}

locals {
  certificate_arn = var.use_localstack ? (length(null_resource.acm_mock) > 0 ? null_resource.acm_mock[0].triggers.certificate_arn : "") : (length(aws_acm_certificate.server) > 0 ? aws_acm_certificate.server[0].arn : "")
}

# Create Client VPN Endpoint
resource "aws_ec2_client_vpn_endpoint" "vpn" {
  count = var.use_localstack ? 0 : 1
  
  description            = "${var.prefix}-eks-vpn-${var.environment}"
  server_certificate_arn = local.certificate_arn
  client_cidr_block      = var.vpn_client_cidr
  split_tunnel           = var.vpn_split_tunnel

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = local.certificate_arn
  }

  connection_log_options {
    enabled               = var.vpn_enable_logs
    cloudwatch_log_group  = var.vpn_enable_logs ? aws_cloudwatch_log_group.vpn_logs[0].name : null
    cloudwatch_log_stream = var.vpn_enable_logs ? aws_cloudwatch_log_stream.vpn_logs[0].name : null
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-eks-vpn-${var.environment}"
    }
  )
}

# CloudWatch Log Group for VPN logs
resource "aws_cloudwatch_log_group" "vpn_logs" {
  count = var.vpn_enable_logs && !var.use_localstack ? 1 : 0
  
  name              = "/aws/vpn/${var.prefix}-${var.environment}"
  retention_in_days = var.vpn_log_retention_days
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-vpn-logs-${var.environment}"
    }
  )
}

resource "aws_cloudwatch_log_stream" "vpn_logs" {
  count = var.vpn_enable_logs && !var.use_localstack ? 1 : 0
  
  name           = "vpn-connection-logs"
  log_group_name = aws_cloudwatch_log_group.vpn_logs[0].name
}

# Associate VPN with subnets
resource "aws_ec2_client_vpn_network_association" "vpn_subnet" {
  count = !var.use_localstack ? length(var.private_subnet_ids) : 0
  
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn[0].id
  subnet_id              = var.private_subnet_ids[count.index]
}

# Authorization rules for access
resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_all" {
  count = !var.use_localstack ? 1 : 0
  
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn[0].id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
}

# Routes for VPC access
resource "aws_ec2_client_vpn_route" "vpn_route" {
  count = var.vpn_split_tunnel && !var.use_localstack ? 1 : 0
  
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn[0].id
  destination_cidr_block = var.vpc_cidr
  target_vpc_subnet_id   = var.private_subnet_ids[0]
}

# Create Security Group for VPN
resource "aws_security_group" "vpn_sg" {
  name        = "${var.prefix}-vpn-sg-${var.environment}"
  description = "Security group for VPN connection to EKS"
  vpc_id      = var.vpc_id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-vpn-sg-${var.environment}"
    }
  )
}

# Security Group Rules
resource "aws_security_group_rule" "vpn_to_eks" {
  security_group_id        = var.eks_cluster_sg_id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpn_sg.id
  description              = "Allow VPN access to EKS API"
}