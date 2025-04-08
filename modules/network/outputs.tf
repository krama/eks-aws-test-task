# Output variables for network infrastructure module

output "vpc_id" {
  description = "ID of created VPC"
  value       = aws_vpc.eks_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of VPC"
  value       = aws_vpc.eks_vpc.cidr_block
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnets_cidr_blocks" {
  description = "CIDR blocks of private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "public_subnets_cidr_blocks" {
  description = "CIDR blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "availability_zones" {
  description = "Used availability zones"
  value       = local.azs
}

output "nat_gateway_ids" {
  description = "IDs of created NAT gateways"
  value       = aws_nat_gateway.nat_gw[*].id
}

output "internet_gateway_id" {
  description = "ID of created Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "private_route_table_ids" {
  description = "IDs of route tables for private subnets"
  value       = aws_route_table.private[*].id
}

output "public_route_table_id" {
  description = "ID of route table for public subnets"
  value       = aws_route_table.public.id
}