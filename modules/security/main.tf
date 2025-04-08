# Security module for EKS cluster

# Retrieve current AWS account information
data "aws_caller_identity" "current" {}

# Get current AWS region data
data "aws_region" "current" {}

# Create Security Group for pods that need access to AWS services via PrivateLink
resource "aws_security_group" "pods_aws_services_sg" {
  name        = "${var.prefix}-pods-aws-services-sg-${var.environment}"
  description = "Security group for pods that need access to AWS services via PrivateLink"
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
      Name = "${var.prefix}-pods-aws-services-sg-${var.environment}"
    }
  )
}

# Create Security Group for pods intercommunication
resource "aws_security_group" "pods_communication_sg" {
  name        = "${var.prefix}-pods-communication-sg-${var.environment}"
  description = "Security group for pods intercommunication"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    self            = true
    description     = "Allow all TCP traffic between pods with this security group"
  }
  
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "udp"
    self            = true
    description     = "Allow all UDP traffic between pods with this security group"
  }
  
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
      Name = "${var.prefix}-pods-communication-sg-${var.environment}"
    }
  )
}

# Create Security Group for databases
resource "aws_security_group" "database_sg" {
  name        = "${var.prefix}-database-sg-${var.environment}"
  description = "Security group for database access from EKS pods"
  vpc_id      = var.vpc_id
  
  # Allow incoming traffic to Postgres
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.pods_aws_services_sg.id]
    description     = "Allow PostgreSQL traffic from pods"
  }
  
  # Allow incoming traffic to MySQL
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.pods_aws_services_sg.id]
    description     = "Allow MySQL traffic from pods"
  }
  
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
      Name = "${var.prefix}-database-sg-${var.environment}"
    }
  )
}

# Create IAM policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.prefix}-s3-access-policy-${var.environment}"
  description = "Policy for S3 access from EKS pods"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.prefix}-${var.environment}-*/*",
          "arn:aws:s3:::${var.prefix}-${var.environment}-*"
        ]
      }
    ]
  })
}

# Create IAM role for S3 access via IRSA (IAM Roles for Service Accounts)
resource "aws_iam_role" "s3_access_role" {
  name = "${var.prefix}-s3-access-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_arn, "/^(.+)\\/(.+)$/", "$2")}:sub": "system:serviceaccount:default:s3-access-sa"
        }
      }
    }]
  })
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-s3-access-role-${var.environment}"
    }
  )
}

# Attach policy to S3 access role
resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Create IAM policy for SQS access
resource "aws_iam_policy" "sqs_access_policy" {
  name        = "${var.prefix}-sqs-access-policy-${var.environment}"
  description = "Policy for SQS access from EKS pods"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ListQueues"
        ],
        Resource = [
          "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.prefix}-${var.environment}-*"
        ]
      }
    ]
  })
}

# Create IAM role for SQS access via IRSA
resource "aws_iam_role" "sqs_access_role" {
  name = "${var.prefix}-sqs-access-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_arn, "/^(.+)\\/(.+)$/", "$2")}:sub": "system:serviceaccount:default:sqs-access-sa"
        }
      }
    }]
  })
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-sqs-access-role-${var.environment}"
    }
  )
}

# Attach policy to SQS access role
resource "aws_iam_role_policy_attachment" "sqs_access_attachment" {
  role       = aws_iam_role.sqs_access_role.name
  policy_arn = aws_iam_policy.sqs_access_policy.arn
}

# Create IAM policy with basic permissions for EKS nodes
resource "aws_iam_policy" "eks_node_additional_policy" {
  name        = "${var.prefix}-eks-node-additional-policy-${var.environment}"
  description = "Additional policy for EKS nodes in ${var.environment} environment"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach additional policy to node groups if specified
locals {
  node_groups_count = length(keys(var.eks_managed_node_groups))
}

resource "aws_iam_role_policy_attachment" "node_groups_additional_policy" {
  count = var.attach_node_additional_policy ? 1 : 0
  
  policy_arn = aws_iam_policy.eks_node_additional_policy.arn
  role       = var.eks_node_role_name
}

# Create AWS Secrets Manager secrets for storing sensitive data
resource "aws_secretsmanager_secret" "database_credentials" {
  count = var.create_database_secrets ? 1 : 0
  
  name        = "${var.prefix}-db-credentials-${var.environment}"
  description = "Database credentials for ${var.environment} environment"
  
  # Enable recovery for important secrets in production
  recovery_window_in_days = var.environment == "prod" ? 30 : 7
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-db-credentials-${var.environment}"
    }
  )
}

# Create KMS key for encrypting sensitive data
resource "aws_kms_key" "eks_secrets_key" {
  description             = "KMS key for ${var.environment} environment EKS secrets"
  deletion_window_in_days = var.environment == "prod" ? 30 : 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_node_role_name}"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-eks-secrets-key-${var.environment}"
    }
  )
}

# Create alias for KMS key
resource "aws_kms_alias" "eks_secrets_key_alias" {
  name          = "alias/${var.prefix}-eks-secrets-${var.environment}"
  target_key_id = aws_kms_key.eks_secrets_key.key_id
}