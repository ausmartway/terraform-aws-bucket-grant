output "policy_id" {
  description = "The ID of the S3 access IAM policy"
  value       = aws_iam_role_policy.s3_access.id
}

output "policy_name" {
  description = "The name of the S3 access IAM policy"
  value       = aws_iam_role_policy.s3_access.name
}

output "granted_permissions" {
  description = "Complete list of S3 permissions granted by this module"
  value       = local.permissions
}

output "bucket_arns" {
  description = "List of S3 bucket ARNs this policy grants access to"
  value       = var.bucket_arns
}

output "permission_level" {
  description = "The permission level used (or 'custom' if custom_permissions was provided)"
  value       = var.custom_permissions != null ? "custom" : var.permission_level
}
