# VPN Module для доступа к кластеру EKS

# Получаем данные о текущем AWS аккаунте
data "aws_caller_identity" "current" {}

# Данные о текущем AWS регионе
data "aws_region" "current" {}

# Создаем клиентский сертификат (самоподписанный для примера)
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

# Загружаем сертификаты в ACM
resource "aws_acm_certificate" "server" {
  private_key       = tls_private_key.server.private_key_pem
  certificate_body  = tls_locally_signed_cert.server.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem
}

# Создаем Client VPN Endpoint
resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description            = "${var.prefix}-eks-vpn-${var.environment}"
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = var.vpn_client_cidr
  split_tunnel           = var.vpn_split_tunnel

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.server.arn
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

# CloudWatch Log Group для логов VPN
resource "aws_cloudwatch_log_group" "vpn_logs" {
  count = var.vpn_enable_logs ? 1 : 0
  
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
  count = var.vpn_enable_logs ? 1 : 0
  
  name           = "vpn-connection-logs"
  log_group_name = aws_cloudwatch_log_group.vpn_logs[0].name
}

# Связываем VPN с подсетями
resource "aws_ec2_client_vpn_network_association" "vpn_subnet" {
  count = length(var.private_subnet_ids)
  
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = var.private_subnet_ids[count.index]
}

# Правила авторизации для доступа
resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_all" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
}

# Правила для доступа к VPC
resource "aws_ec2_client_vpn_route" "vpn_route" {
  count = var.vpn_split_tunnel ? 1 : 0
  
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  destination_cidr_block = var.vpc_cidr
  target_vpc_subnet_id   = var.private_subnet_ids[0]
}

# Создаем Security Group для VPN
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

# Правила Security Group
resource "aws_security_group_rule" "vpn_to_eks" {
  security_group_id        = var.eks_cluster_sg_id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpn_sg.id
  description              = "Allow VPN access to EKS API"
}