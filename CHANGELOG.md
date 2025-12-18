# Changelog

All notable changes to the bucket-grant module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2024-12-18

### Changed
- Updated Terraform version requirement from `>= 1.0` to `>= 1.10`
- Updated AWS Provider version requirement from `>= 4.0` to `>= 6.0`
- Updated all example files to use Terraform `>= 1.10` and AWS Provider `~> 6.0`
- **BREAKING: Simplified to bucket-level permissions only**: Removed object-level ARN handling for simpler demos. All permissions now apply to bucket ARNs only (`arn:aws:s3:::bucket-name`)

### Added
- Added `tags` variable to support optional tagging of IAM policies
- Added `.gitignore` file with Terraform standard ignores
- Added MIT `LICENSE` file

### Fixed
- Removed duplicate `terraform` block from main.tf (consolidated in version.tf)

### Removed
- Removed `banking-least-privilege-example.tf` from examples for simplicity
- Removed `PRESENTATION.md` - no longer needed
- Removed `QUICKSTART.md` - content merged into README.md

### Improved
- Better resource organization and code structure
- Enhanced module metadata
- Simplified output structure with single `policy_id` and `policy_name` outputs
- Streamlined documentation to focus on core functionality
- Consolidated all documentation into single README.md for easier maintenance

## [1.0.0] - 2024-12-18

### Added
- Initial release of bucket-grant module
- Support for preset permission levels: `read`, `write`, `read_write`, `delete`, `full`
- Custom permissions support via `custom_permissions` variable
- Multi-bucket support through `bucket_arns` list
- Automatic separation of bucket-level and object-level IAM permissions
- Service-agnostic design (works with Lambda, EC2, ECS, EKS, etc.)
- Input validation for bucket ARNs and permission levels
- Comprehensive outputs including policy IDs, names, and granted permissions
- Two example configurations:
  - Lambda function with S3 read access
  - ECS task with multi-bucket access
- Full documentation in README.md

### Features
- **Least Privilege by Default**: Automatically scopes permissions to specific buckets and actions
- **Pulumi/CDK-like Experience**: Simplified `bucket.grant()` style API for Terraform
- **Banking/Enterprise Ready**: Compliance-focused with clear audit trails
- **Flexible**: Supports both preset levels and custom permission lists
- **Well-Documented**: Comprehensive examples and usage patterns

### Requirements
- Terraform >= 1.0
- AWS Provider >= 4.0

### Notes
This module was created to address the challenge of implementing least privilege IAM policies
for S3 bucket access in Terraform, providing a more developer-friendly experience similar to
Pulumi and AWS CDK's grant methods.
