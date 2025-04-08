# Network infrastructure module for EKS

# Retrieve available availability zones in the region
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Get availability zone names (eu-central-2a, eu-central-2b, eu-central-2c)
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  
  # Determine the number of NAT gateways based on the setting
  nat_gateway_count = var.single_nat_gateway ? 1 : length(local.azs)
}

# Create VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-vpc-${var.environment}"
      "kubernetes.io/cluster/${var.prefix}-${var.environment}-eks-cluster" = "shared"
    }
  )
}

# Create public subnets (one in each AZ)
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-public-subnet-${var.environment}-${local.azs[count.index]}"
      "kubernetes.io/cluster/${var.prefix}-${var.environment}-eks-cluster" = "shared"
      "kubernetes.io/role/elb" = "1"  # Tag for AWS Load Balancer Controller
    }
  )
}

# Create private subnets (one in each AZ)
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-private-subnet-${var.environment}-${local.azs[count.index]}"
      "kubernetes.io/cluster/${var.prefix}-${var.environment}-eks-cluster" = "shared"
      "kubernetes.io/role/internal-elb" = "1"  # Tag for AWS Load Balancer Controller
    }
  )
}

# Create Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-igw-${var.environment}"
    }
  )
}

# Create Elastic IP for NAT gateways
resource "aws_eip" "nat" {
  count = local.nat_gateway_count
  
  domain = "vpc"
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-nat-eip-${var.environment}-${count.index + 1}"
    }
  )
}

# Create NAT gateways for private subnets
resource "aws_nat_gateway" "nat_gw" {
  count = local.nat_gateway_count
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  depends_on = [aws_internet_gateway.igw]
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-nat-gw-${var.environment}-${count.index + 1}"
    }
  )
}

# Create route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-public-rt-${var.environment}"
    }
  )
}

# Create route through Internet Gateway
resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate route table with public subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create route tables for private subnets
resource "aws_route_table" "private" {
  count = var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)
  
  vpc_id = aws_vpc.eks_vpc.id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-private-rt-${var.environment}${var.single_nat_gateway ? "" : "-${count.index + 1}"}"
    }
  )
}

# Create routes through NAT gateway
resource "aws_route" "private_nat" {
  count = var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)
  
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[var.single_nat_gateway ? 0 : count.index].id
}

# Associate route tables with private subnets
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}

# VPC Flow Logs for traffic monitoring (especially important for Prod environment)
resource "aws_flow_log" "vpc_flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  
  iam_role_arn    = aws_iam_role.flow_log_role[0].arn
  log_destination = aws_cloudwatch_log_group.flow_log[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.eks_vpc.id
}

# IAM role for VPC Flow Logs
resource "aws_iam_role" "flow_log_role" {
  count = var.enable_flow_logs ? 1 : 0
  
  name = "${var.prefix}-flow-log-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  
  name = "/aws/vpc-flow-log/${aws_vpc.eks_vpc.id}"
  retention_in_days = var.flow_log_retention_days
}

# Policy for IAM role for VPC Flow Logs
resource "aws_iam_role_policy" "flow_log_policy" {
  count = var.enable_flow_logs ? 1 : 0
  
  name = "${var.prefix}-flow-log-policy-${var.environment}"
  role = aws_iam_role.flow_log_role[0].id
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      Effect = "Allow",
      Resource = "*"
    }]
  })
}
