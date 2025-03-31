provider "aws" {
  region = var.region
  
  # Increase plugin timeout to prevent "timeout while waiting for plugin to start" errors
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
}

# Configure Terraform backend for state management
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
} 