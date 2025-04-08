## Project Features
Modularity: Each infrastructure component is placed in a separate module, ensuring better code organization and reusability.

Environment configurations: Separate tfvars files for each environment (dev, stage, qa, prod).
Separation of concerns:

- The network module handles VPC, subnets, and NAT gateways
- The EKS module creates and configures the cluster
- The Load Balancer module sets up the ALB and related components
- The security module manages IAM roles, policies, and security groups
- The addons module installs necessary addons into the cluster

Scalability: The structure allows for easy addition of new modules or extension of existing ones.

## Project structure
eks-aws-terraform/
│
├── backend.tf                # Terraform backend configuration
├── locals.tf                 # Local variables 
├── main.tf                   # Main file, combining all modules
├── outputs.tf                # Output variables
├── providers.tf              # Providers configuration
├── variables.tf              # Variable declarations
├── versions.tf               # Terraform and provider versions
│
├── environments/             # Configurations for different environments
│   ├── dev.tfvars            # Variables for dev environment
│   ├── stage.tfvars          # Variables for stage environment
│   ├── qa.tfvars             # Variables for qa environment
│   └── prod.tfvars           # Variables for prod environment
│
└── modules/                  # Modules for various infrastructure components
    ├── network/              # Network infrastructure module
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    ├── eks/                  # EKS cluster module
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    ├── load-balancer/        # ALB and related resources module
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    ├── security/             # Security module
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    ├── monitoring/           # Monitoring module
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    └── addons/               # EKS addons module
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
