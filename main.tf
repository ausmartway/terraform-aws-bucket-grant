# S3 bucket access policy
resource "aws_iam_role_policy" "s3_access" {
  name = var.policy_name != null ? var.policy_name : "${var.role_name}-s3-${var.permission_level}"
  role = var.role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "S3BucketAccess"
      Effect   = "Allow"
      Action   = local.permissions
      Resource = var.bucket_arns
    }]
  })
}
