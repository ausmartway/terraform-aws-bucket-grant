variable "role_name" {
  description = "The name or ID of the IAM role to attach the policy to (supports Lambda, EC2, ECS, EKS, Glue, Step Functions, etc.)"
  type        = string
}

variable "bucket_arns" {
  description = "List of S3 bucket ARNs to grant access to. Example: ['arn:aws:s3:::my-bucket']"
  type        = list(string)
  
  validation {
    condition     = length(var.bucket_arns) > 0
    error_message = "At least one bucket ARN must be provided"
  }
  
  validation {
    condition     = alltrue([for arn in var.bucket_arns : can(regex("^arn:aws:s3:::", arn))])
    error_message = "All bucket ARNs must start with 'arn:aws:s3:::'"
  }
}

variable "permission_level" {
  description = "Permission level: read, write, read_write, delete, or full"
  type        = string
  default     = "read"
  
  validation {
    condition     = contains(["read", "write", "read_write", "delete", "full"], var.permission_level)
    error_message = "Permission level must be one of: read, write, read_write, delete, full"
  }
}

variable "custom_permissions" {
  description = "Optional: Custom list of S3 actions. Overrides permission_level if set. Example: ['s3:GetObject', 's3:PutObject']"
  type        = list(string)
  default     = null
}

variable "policy_name" {
  description = "Name of the IAM policy. If not provided, will be auto-generated based on role name and permission level."
  type        = string
  default     = null
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "Managed by Terraform - S3 bucket access policy"
}

variable "tags" {
  description = "Optional tags to apply to IAM policies for resource tracking and organization"
  type        = map(string)
  default     = {}
}
