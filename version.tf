# Version metadata for the bucket-grant module

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

# Module metadata
locals {
  module_version = "1.1.0"
  module_name    = "bucket-grant"
  module_description = "Terraform module for managing S3 bucket access with least privilege IAM policies"

  # Module tags that can be merged with resource tags
  module_tags = {
    Module        = "bucket-grant"
    ModuleVersion = local.module_version
    ManagedBy     = "Terraform"
  }
}
