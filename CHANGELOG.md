# Changelog

All notable changes to the bucket-grant module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of bucket-grant Terraform module
- Support for preset permission levels: `read`, `write`, `read_write`, `delete`, `full`
- Custom permissions support via `custom_permissions` variable
- Multi-bucket support through `bucket_arns` list
- Service-agnostic design (works with Lambda, EC2, ECS, EKS, Glue, Step Functions, etc.)
- Input validation for bucket ARNs and permission levels
- Comprehensive outputs including policy IDs, names, and granted permissions
- Optional tagging support via `tags` variable
- Example configurations:
  - Lambda function with S3 read access
  - ECS task with multi-bucket read/write access
- Comprehensive documentation in README.md

### Features
- **Least Privilege by Default**: Scopes permissions to specific buckets and actions
- **Pulumi/CDK-like Experience**: Simplified `bucket.grant()` style API for Terraform
- **Flexible**: Supports both preset levels and custom permission lists
- **Well-Documented**: Comprehensive examples and usage patterns

### Requirements
- Terraform >= 1.10
- AWS Provider >= 6.0
