# Terraform backend configuration for storing state

terraform {
  # For production use S3 backend with locks through DynamoDB
  # backend "s3" {
  #   bucket         = "eks-terraform-state"           # S3 bucket for Terraform state
  #   key            = "eks/terraform.tfstate"         # Path to Terraform state file
  #   region         = "eu-central-2"                  # S3 bucket region
  #   encrypt        = true                            # Encrypt Terraform state
  #   dynamodb_table = "eks-terraform-locks"           # DynamoDB table for locks
  # }
}

# Block for preparing S3 bucket and DynamoDB table (uncomment when running for the first time)
/*
provider "aws" {
  region = "eu-central-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "eks-terraform-state"
  
  # Enable versioning for restoring previous states
  versioning {
    enabled = true
  }
  
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "eks-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}
*/
