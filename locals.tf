locals {
  # Permission presets for common S3 access patterns
  permission_presets = {
    read = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    write = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    read_write = concat(
      local.permission_presets.read,
      local.permission_presets.write
    )
    delete = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    full = concat(
      local.permission_presets.read,
      local.permission_presets.write,
      local.permission_presets.delete,
      [
        "s3:DeleteBucket",
        "s3:PutBucketPolicy",
        "s3:GetBucketPolicy"
      ]
    )
  }

  # Determine which permissions to use - custom overrides preset
  permissions = var.custom_permissions != null ? var.custom_permissions : local.permission_presets[var.permission_level]
}
