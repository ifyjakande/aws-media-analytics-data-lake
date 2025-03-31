provider "aws" {
  region = var.region
  
  # Prevent timeout issues during development
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
}

# Set up Terraform with required provider versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
} 