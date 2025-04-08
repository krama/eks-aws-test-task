# Modular EKS Cluster Infrastructure

The project implements a modular system for deploying EKS clusters in AWS, with support for working through Application Load Balancer (ALB) and following best practices.

## Overview of Architecture

The infrastructure is divided into the following logical modules:

1. **Network module** - responsible for creating VPC, subnets, NAT gateways, route tables, and other network components
2. **EKS module** - creates and configures the EKS cluster, node groups, and associated IAM roles
3. **Security module** - configures IAM roles, policies, Security Groups, and secrets for securing the infrastructure
4. **Load Balancer module** - configures the AWS Load Balancer Controller for managing ALB in Kubernetes
5. **Add-ons module** - installs additional components in the cluster: Cluster Autoscaler, Metrics Server, etc.
6. **Monitoring module** - configures monitoring tools: Prometheus, CloudWatch Dashboard, and Alarms

## Environments

Configurations are created for four different environments:

1. **Development (dev)** - environment for development and testing
2. **Staging (stage)** - environment for pre-production testing
3. **QA** - environment for quality assurance testing
4. **Production (prod)** - production environment for end-users

## Key Features for Each Environment

### Development (dev)

- **Cost optimization**:
  - Uses t3.small instances for cost savings
  - Minimal number of nodes (1, scalable to 3)
  - One NAT gateway for cost savings
  - Short log retention period (7 days)
  - Prometheus not installed for cost savings

- **Security**:
  - Public access to API cluster is open for simplified development
  - All components are launched in one node group
  - Basic configuration of KMS keys with short recovery period (7 days)

- **Network**:
  - VPC CIDR: 10.10.0.0/16
  - One NAT gateway for all private subnets

### Staging (stage)

- **Balance between cost and performance**:
  - Uses t3.medium instances
  - More nodes (2, scalable to 5)
  - One NAT gateway (compromise between cost and availability)
  - Longer log retention period (14 days)

- **Security**:
  - Public access to API cluster is restricted to corporate IP range
  - Workload and system components are separated by node groups
  - Additional IAM policies for access to AWS services

- **Network**:
  - VPC CIDR: 10.20.0.0/16
  - One NAT gateway for all private subnets

### QA

- **High availability**:
  - Uses a combination of t3.medium and t3.large instances
  - Uses Spot instances for workloads for cost optimization
  - OnDemand instances for system components
  - Separate NAT gateways for each availability zone
  - Longer log retention period (30 days)

- **Security**:
  - Public access to API cluster is restricted to corporate IP range
  - Separate node group for monitoring
  - EBS CSI driver installed for persistent storage
  - Uses service accounts with IRSA for access to AWS services
  - Separate Security Groups for different workload types

- **Network**:
  - VPC CIDR: 10.30.0.0/16
  - Separate NAT gateway for each availability zone

### Production (prod)

- **Maximum availability and high performance**:
  - Uses m5.large instances with high performance
  - Large number of nodes (9, scalable to 30)
  - Node distribution across multiple availability zones
  - Separate NAT gateways for each availability zone
  - Longer log retention period (90 days)

- **Security**:
  - Public access to API cluster is closed
  - Strict node group separation by availability zone and workload type
  - KMS encryption with increased recovery period (30 days)
  - Separate node group for monitoring with larger storage
  - Strict IAM policies following the principle of least privilege
  - Uses AWS Secrets Manager for storing sensitive data

- **Network**:
  - VPC CIDR: 10.40.0.0/16
  - Separate NAT gateway for each availability zone

## AWS Best Practices Used

### Network and Infrastructure

- **Multi-AZ deployment** - uses three availability zones in eu-central-2 for maximum availability
- **Separate subnets** - public subnets for ALB, private subnets for EKS nodes
- **Proper Kubernetes tags** - uses special tags for integration with AWS Load Balancer Controller
- **VPC Flow Logs** - monitors network traffic
- **Terraform state in S3** - stores state in S3 with locks through DynamoDB

### Security

- **Principle of least privilege** - IAM roles and policies with minimal necessary permissions
- **OIDC provider and service accounts** - secure connection between Kubernetes and AWS IAM
- **Security Groups** - strict rules for incoming and outgoing traffic
- **KMS encryption** - encrypts secrets in the EKS cluster with AWS KMS
- **Private API endpoint** - closed API endpoint in production environment
- **AWS Secrets Manager** - securely stores sensitive data
- **Separation of access** - different IAM roles for administrators and developers

### Scalability and Availability

- **Cluster Autoscaler** - automatically scales EKS cluster nodes
- **Horizontal Pod Autoscaler** - automatically scales applications
- **Multi-AZ distribution** - distributes nodes across multiple availability zones
- **Prometheus monitoring** - monitors cluster and application performance
- **CloudWatch Alarms** - alerts for critical issues
- **Separation of node groups** - separates system and user workloads

### Working with ALB

- **AWS Load Balancer Controller** - manages ALB from Kubernetes
- **Ingress resources** - creates load balancers through Kubernetes API
- **Public/private load balancers** - flexible configuration of service accessibility
- **SSL/TLS termination** - encrypts traffic with certificates
- **Sticky sessions** - supports session persistence for applications that require it
- **Cross-Zone load balancing** - evenly distributes traffic across availability zones

## Additional Recommendations for Implementation

1. **CI/CD integration**:
   - Use GitOps approach with ArgoCD or Flux for synchronizing Kubernetes resources with the repository
   - Create a pipeline for validating and applying Terraform configuration

2. **Secrets management**:
   - Use AWS Secrets Manager or HashiCorp Vault for managing sensitive data
   - Integrate external-secrets operator for synchronizing secrets in Kubernetes

3. **Logging and auditing**:
   - Set up EFK (Elasticsearch, Fluentd, Kibana) or CloudWatch for centralized log collection
   - Enable AWS CloudTrail for API call auditing

4. **Backup and restore**:
   - Set up regular backups of Kubernetes resources with Velero
   - Create a disaster recovery plan

5. **Cluster updates**:
   - Follow the Blue/Green deployment process for updating the cluster with minimal downtime
   - Regularly update the EKS cluster for using new features and security patches
   - Use managed node groups for simplifying node updates

6. **Cost optimization**:
   - Use Spot instances for non-critical workloads
   - Set up automatic scaling for efficient resource usage
   - Use EC2 Savings Plans or Reserved Instances for stable workloads
   - Regularly analyze resource usage and optimize node groups

7. **Monitoring and alerts**:
   - Create complex dashboards for visualizing metrics
   - Set up alerts for different metrics (CPU, memory, storage, latency)
   - Use AWS X-Ray for distributed tracing
