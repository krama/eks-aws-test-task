# Load Balancer Module for EKS

# Retrieve current AWS account information
data "aws_caller_identity" "current" {}

# Get current AWS region data
data "aws_region" "current" {}

locals {
  # Service account name for AWS Load Balancer Controller
  aws_lb_controller_sa_name = "aws-load-balancer-controller"
  
  # Namespace name for AWS Load Balancer Controller
  aws_lb_controller_namespace = "kube-system"
}

# Create IAM policy for AWS Load Balancer Controller
resource "aws_iam_policy" "aws_lb_controller_policy" {
  name        = "${var.prefix}-aws-lb-controller-${var.environment}"
  description = "Policy for AWS Load Balancer Controller"
  
  # Use the recommended policy from AWS
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateServiceLinkedRole"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateSecurityGroup"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateTags"
        ],
        Resource = "arn:aws:ec2:*:*:security-group/*",
        Condition = {
          StringEquals = {
            "ec2:CreateAction": "CreateSecurityGroup"
          },
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        Resource = "arn:aws:ec2:*:*:security-group/*",
        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
            "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup"
        ],
        Resource = "*",
        Condition = {
          Null = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup"
        ],
        Resource = "*",
        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ],
        Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        Resource = "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*"
      },
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        Resource = "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
      },
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteTargetGroup"
        ],
        Resource = "*",
        Condition = {
          Null = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
          }
        }
      }
    ]
  })
}

# Create IAM role for AWS Load Balancer Controller service account
resource "aws_iam_role" "aws_lb_controller_role" {
  name = "${var.prefix}-aws-lb-controller-role-${var.environment}"
  
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
          "${replace(var.oidc_provider_arn, "/^(.+)\\/(.+)$/", "$2")}:sub": "system:serviceaccount:${local.aws_lb_controller_namespace}:${local.aws_lb_controller_sa_name}"
        }
      }
    }]
  })
}

# Attach policy to AWS Load Balancer Controller role
resource "aws_iam_role_policy_attachment" "aws_lb_controller_role_attachment" {
  role       = aws_iam_role.aws_lb_controller_role.name
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
}

# Create Kubernetes service account for AWS Load Balancer Controller
resource "kubernetes_service_account" "aws_lb_controller_sa" {
  count = var.create_service_account && !var.use_localstack ? 1 : 0
  
  metadata {
    name      = local.aws_lb_controller_sa_name
    namespace = local.aws_lb_controller_namespace
    
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller_role.arn
    }
    
    labels = {
      "app.kubernetes.io/name"      = local.aws_lb_controller_sa_name
      "app.kubernetes.io/component" = "controller"
    }
  }
}

# Install AWS Load Balancer Controller via Helm if enabled
resource "helm_release" "aws_load_balancer_controller" {
  count = var.install_aws_load_balancer_controller && !var.use_localstack ? 1 : 0
  
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = local.aws_lb_controller_namespace
  version    = var.aws_load_balancer_controller_chart_version
  
  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }
  
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  
  set {
    name  = "serviceAccount.name"
    value = local.aws_lb_controller_sa_name
  }
  
  # Set AWS region
  set {
    name  = "region"
    value = data.aws_region.current.name
  }
  
  # Set VPC ID
  set {
    name  = "vpcId"
    value = var.vpc_id
  }
  
  # AWS ALB Controller settings for version 2.4.x
  set {
    name  = "enableServiceMutatorWebhook"
    value = "true"
  }
  
  # Configure container resources
  set {
    name  = "resources.requests.cpu"
    value = var.controller_cpu_request
  }
  
  set {
    name  = "resources.requests.memory"
    value = var.controller_memory_request
  }
  
  set {
    name  = "resources.limits.cpu"
    value = var.controller_cpu_limit
  }
  
  set {
    name  = "resources.limits.memory"
    value = var.controller_memory_limit
  }
  
  depends_on = [
    kubernetes_service_account.aws_lb_controller_sa
  ]
}

# Create SecurityGroup for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.prefix}-alb-sg-${var.environment}"
  description = "Security group for Application Load Balancers in EKS"
  vpc_id      = var.vpc_id
  
  # Allow inbound HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }
  
  # Allow inbound HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic"
  }
  
  # Allow all outbound traffic
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
      Name = "${var.prefix}-alb-sg-${var.environment}"
    }
  )
}