# Modular EKS Infrastructure

This project represents a modular system for deploying EKS clusters in AWS with support for working with Application Load Balancer (ALB) and following best practices, implementing GitOps principles.

## Architecture Overview

The infrastructure is divided into the following logical modules:

1. **Network Module** - responsible for creating VPC, subnets, NAT gateways, route tables, and other network components
2. **EKS Module** - creates and configures an EKS cluster, node groups, and associated IAM roles
3. **Security Module** - configures IAM roles, policies, security groups, and secrets for securing the infrastructure
4. **Load Balancer Module** - configures IAM roles and policies for AWS Load Balancer Controller
5. **Add-ons Module** - configures IAM roles and policies for cluster components: Cluster Autoscaler, Metrics Server, etc.
6. **Monitoring Module** - configures monitoring tools: CloudWatch Dashboard and Alarms
7. **VPN Module** - provides secure access to the EKS cluster API through AWS Client VPN

## GitOps Model

The infrastructure uses a GitOps approach to manage cluster components:

1. **Terraform** is responsible only for:
   - Creating basic AWS infrastructure (VPC, subnets, IAM, EKS, VPN)
   - Creating IAM roles and policies for cluster components

## Environments

Configurations are created for four different environments:

1. **Development (dev)** - environment for development and testing
2. **Staging (stage)** - environment for pre-production testing
3. **QA** - environment for quality assurance testing
4. **Production (prod)** - production environment for end-users

## Key Features for Each Environment

### Development (dev)

- **Cost Optimization**:
  - Uses t3.small instances for cost savings
  - Minimum number of nodes (1, scales up to 3)
  - One NAT gateway for cost savings
  - Short log retention period (7 days)

- **Security**:
  - Access to the cluster API is restricted through VPN
  - All components run in one node group
  - Basic KMS configuration with a short recovery period (7 days)

- **Network**:
  - VPC CIDR: 10.10.0.0/16
  - One NAT gateway for all private subnets
  - VPN for secure access to the cluster

### Staging (stage)

- **Balancing Cost and Performance**:
  - Uses t3.medium instances
  - More nodes (2, scales up to 5)
  - One NAT gateway (compromise between cost and availability)
  - Longer log retention period (14 days)

- **Security**:
  - Access to the cluster API is restricted through VPN
  - Workloads and system components are separated by node groups
  - Additional IAM policies for accessing AWS services

- **Network**:
  - VPC CIDR: 10.20.0.0/16
  - One NAT gateway for all private subnets
  - VPN for secure access to the cluster

### QA

- **High Availability**:
  - Uses a combination of t3.medium and t3.large instances
  - Uses Spot instances for workloads to optimize costs
  - OnDemand instances for system components
  - Separate NAT gateways for each availability zone
  - Longer log retention period (30 days)

- **Security**:
  - Access to the cluster API is restricted through VPN
  - Separate node group for monitoring
  - EBS CSI driver for persistent storage
  - Service accounts with IRSA for accessing AWS services
  - Separate security groups for different types of workloads

- **Network**:
  - VPC CIDR: 10.30.0.0/16
  - Separate NAT gateway for each availability zone
  - VPN for secure access to the cluster

### Production (prod)

- **Maximum Availability and High Performance**:
  - Uses m5.large instances with high performance
  - Large number of nodes (9, scales up to 30)
  - Nodes distributed across multiple availability zones
  - Separate NAT gateways for each availability zone
  - Longer log retention period (90 days)

- **Security**:
  - Access to the cluster API is restricted through VPN
  - Strict separation of node groups by availability zone and workload type
  - KMS configuration with a longer recovery period (30 days)
  - Separate node group for monitoring with a large amount of storage
  - Strict IAM policies, following the principle of least privilege
  - AWS Secrets Manager for storing sensitive data

- **Network**:
  - VPC CIDR: 10.40.0.0/16
  - Separate NAT gateway for each availability zone
  - VPN for secure access to the cluster

## AWS Best Practices Used

### Network and Infrastructure

- **Deploy to Multiple Availability Zones** - uses three availability zones in eu-central-2 for maximum availability
- **Use Separate Subnets** - uses public subnets for ALB and private subnets for EKS nodes
- **Use Correct Kubernetes Tags** - uses special tags for integrating with AWS Load Balancer Controller
- **VPC Flow Logs** - monitors network traffic
- **Terraform State in S3** - stores state in S3 with locks through DynamoDB
- **VPN Access** - provides secure access to the cluster API through AWS Client VPN

### Security

- **Principle of Least Privilege** - uses IAM roles and policies with minimum necessary permissions
- **OIDC Provider and Service Accounts** - securely connects Kubernetes to AWS IAM
- **Security Groups** - has strict rules for incoming and outgoing traffic
- **KMS Encryption** - encrypts secrets in the EKS cluster using AWS KMS
- **Private API Endpoint** - has a closed API endpoint in the production environment
- **AWS Secrets Manager** - securely stores sensitive data
- **Role Separation** - has separate IAM roles for administrators and developers

### Scalability and Availability

- **Cluster Autoscaler** - automatically scales EKS nodes
- **Horizontal Pod Autoscaler** - automatically scales applications
- **Distributed Nodes** - distributes nodes across multiple availability zones
- **CloudWatch Alarms** - notifications for critical issues
- **Node Group Separation** - separates system and user workloads
