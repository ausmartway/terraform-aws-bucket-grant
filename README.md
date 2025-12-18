# Terraform S3 Bucket Grant Module

A Terraform module that simplifies IAM policy management for S3 bucket access, providing a Pulumi/CDK-like experience with `bucket.grant()` style permissions.

## Overview

This module helps you implement **least privilege access** by generating precise IAM policies for S3 bucket access. Instead of overly permissive "swim lane" or resource group approaches, this module creates targeted policies scoped to specific buckets and actions.

## Quick Start

### Step 1: Copy the Module

```bash
# Option A: Place in a modules directory
cp -r bucket-grant /path/to/your/terraform/project/modules/

# Option B: Place at the root level
cp -r bucket-grant /path/to/your/terraform/project/
```

### Step 2: Use in Your Code

```hcl
# Configure AWS Provider
provider "aws" {
  region = "ap-southeast-2"  # Sydney
}

# Your existing S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-application-data"
}

# Your existing IAM role (e.g., for Lambda)
resource "aws_iam_role" "my_lambda_role" {
  name = "my-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Grant read access using the module
module "lambda_s3_access" {
  source = "./modules/bucket-grant"  # Adjust path as needed

  role_name        = aws_iam_role.my_lambda_role.name
  bucket_arns      = [aws_s3_bucket.my_bucket.arn]
  permission_level = "read"
}
```

### Step 3: Apply

```bash
# Initialize Terraform (downloads providers)
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
```

### Step 4: Verify

Check the outputs to confirm permissions:

```bash
terraform output
```

### Key Features

- ✅ **Service Agnostic**: Works with Lambda, EC2, ECS, EKS, Glue, Step Functions, etc.
- ✅ **Simple & Clean**: Single IAM policy with bucket-level permissions
- ✅ **Preset Permission Levels**: `read`, `write`, `read_write`, `delete`, `full`
- ✅ **Custom Permissions**: Override with specific S3 actions when needed
- ✅ **Multi-bucket Support**: Grant access to multiple buckets in a single module call
- ✅ **Validation**: Input validation ensures correct ARN format and required fields
- ✅ **Demo-Friendly**: Minimal complexity, easy to understand and present

---

## Usage Examples

### Basic Examples

#### Lambda Function - Read Access

```hcl
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}

resource "aws_iam_role" "lambda" {
  name = "my-lambda-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

module "lambda_bucket_read" {
  source = "./modules/bucket-grant"
  
  role_name        = aws_iam_role.lambda.name
  bucket_arns      = [aws_s3_bucket.data.arn]
  permission_level = "read"
}

resource "aws_lambda_function" "processor" {
  function_name = "data-processor"
  role          = aws_iam_role.lambda.arn
  # ... other configuration
}
```

#### EC2 Instance - Write Access

```hcl
resource "aws_iam_role" "ec2" {
  name = "my-ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "my-ec2-profile"
  role = aws_iam_role.ec2.name
}

module "ec2_logs_writer" {
  source = "./modules/bucket-grant"
  
  role_name        = aws_iam_role.ec2.name
  bucket_arns      = [aws_s3_bucket.logs.arn]
  permission_level = "write"
  policy_name      = "ec2-logs-writer"
}

resource "aws_instance" "app" {
  ami                  = "ami-12345678"
  instance_type        = "t3.medium"
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  # ... other configuration
}
```

#### ECS Task - Multiple Buckets

```hcl
resource "aws_iam_role" "ecs_task" {
  name = "my-ecs-task-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

module "ecs_multi_bucket_access" {
  source = "./modules/bucket-grant"
  
  role_name = aws_iam_role.ecs_task.name
  bucket_arns = [
    aws_s3_bucket.data.arn,
    aws_s3_bucket.config.arn,
    aws_s3_bucket.cache.arn
  ]
  permission_level = "read_write"
}
```

### Advanced Examples

#### Custom Permissions

```hcl
module "custom_tagging_access" {
  source = "./modules/bucket-grant"
  
  role_name = aws_iam_role.lambda.name
  bucket_arns = [aws_s3_bucket.data.arn]
  
  # Override preset with custom permissions
  custom_permissions = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:GetObjectTagging",
    "s3:PutObjectTagging"
  ]
  
  policy_name = "lambda-tagging-access"
}
```

#### Cross-Account Access

```hcl
module "cross_account_reader" {
  source = "./modules/bucket-grant"
  
  role_name = aws_iam_role.lambda.name
  bucket_arns = [
    "arn:aws:s3:::external-account-bucket"
  ]
  permission_level = "read"
  policy_name      = "cross-account-reader"
}
```

#### Full Access for Admin Operations

```hcl
module "admin_full_access" {
  source = "./modules/bucket-grant"
  
  role_name        = aws_iam_role.admin.name
  bucket_arns      = [aws_s3_bucket.management.arn]
  permission_level = "full"
  policy_name      = "admin-bucket-management"
}
```

---

## Permission Levels

| Level | When to Use | S3 Actions Included |
|-------|-------------|-------------------|
| `read` | Reading files only | GetObject, GetObjectVersion, ListBucket, GetBucketLocation |
| `write` | Writing files only | PutObject, PutObjectAcl |
| `read_write` | Reading AND writing | All `read` + `write` permissions |
| `delete` | Deleting files | DeleteObject, DeleteObjectVersion |
| `full` | Complete control | All `read_write` + `delete` + bucket management (DeleteBucket, PutBucketPolicy, GetBucketPolicy) |

---

## Troubleshooting

### Issue: "Invalid bucket ARN"
**Solution**: Ensure ARNs start with `arn:aws:s3:::`
```hcl
# ❌ Wrong
bucket_arns = ["my-bucket"]

# ✅ Correct
bucket_arns = ["arn:aws:s3:::my-bucket"]
# or use:
bucket_arns = [aws_s3_bucket.my_bucket.arn]
```

### Issue: "No changes detected"
**Solution**: The module only creates policies, not buckets or roles. Ensure your bucket and role resources exist first.

### Issue: "Access Denied" after applying
**Solution**:
1. Verify the role is attached to your service (Lambda, EC2, etc.)
2. Ensure the bucket ARNs are correct
3. For cross-account access, ensure bucket policies also allow access


## Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `role_name` | IAM role name/ID to attach policy to | `string` | - | yes |
| `bucket_arns` | List of S3 bucket ARNs | `list(string)` | - | yes |
| `permission_level` | Permission preset: read, write, read_write, delete, full | `string` | `"read"` | no |
| `custom_permissions` | Custom S3 actions (overrides permission_level) | `list(string)` | `null` | no |
| `policy_name` | Custom policy name | `string` | Auto-generated | no |
| `policy_description` | Policy description | `string` | "Managed by Terraform - S3 bucket access policy" | no |

## Module Outputs

| Name | Description |
|------|-------------|
| `policy_id` | ID of the S3 access IAM policy |
| `policy_name` | Name of the S3 access IAM policy |
| `granted_permissions` | List of all S3 permissions granted |
| `bucket_arns` | List of bucket ARNs policy applies to |
| `permission_level` | Permission level used (or 'custom') |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.10 |
| aws | >= 6.0 |

## How It Works

The module creates a single IAM policy that applies the specified S3 permissions to your bucket ARNs. All permissions are applied at the bucket level for simplicity and ease of demonstration.

## Comparison to Pulumi/CDK

### Pulumi (Python)
```python
bucket.grant_read(lambda_role)
```

### AWS CDK (TypeScript)
```typescript
bucket.grantRead(lambdaFunction);
```

### This Module (Terraform)
```hcl
module "bucket_read" {
  source           = "./modules/bucket-grant"
  role_name        = aws_iam_role.lambda.name
  bucket_arns      = [aws_s3_bucket.data.arn]
  permission_level = "read"
}
```

While slightly more verbose than Pulumi/CDK, this module provides similar **declarative intent** and **least privilege** patterns in Terraform.

---

## Getting Help

- Check the example files in `examples/` folder
- Review AWS IAM documentation: https://docs.aws.amazon.com/iam/
- Review S3 permissions: https://docs.aws.amazon.com/s3/

---

## Contributing

This module can be extended to support additional features:

- ✨ Support for S3 access points
- ✨ KMS encryption key permissions
- ✨ VPC endpoint policies
- ✨ Condition-based access (IP restrictions, MFA, etc.)

## License

This module is provided as-is for use in your Terraform infrastructure.

## Support

For questions or issues with this module, please contact your DevOps or Infrastructure team.
