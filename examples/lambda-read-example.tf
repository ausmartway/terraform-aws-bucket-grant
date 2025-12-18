# Example: Lambda Function with S3 Read Access

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"  # Sydney
}

# S3 bucket for storing data
resource "aws_s3_bucket" "data" {
  bucket = "example-lambda-data-bucket"
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Enable versioning for data protection
resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Lambda execution role
resource "aws_iam_role" "lambda" {
  name = "example-lambda-s3-reader"
  
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
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Attach AWS managed policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Use the bucket-grant module to provide S3 read access
module "lambda_s3_read" {
  source = "../"  # Path to the bucket-grant module
  
  role_name        = aws_iam_role.lambda.name
  bucket_arns      = [aws_s3_bucket.data.arn]
  permission_level = "read"
  policy_name      = "lambda-read-data-bucket"
}

# Lambda function
resource "aws_lambda_function" "processor" {
  filename      = "lambda_function.zip"  # You would create this separately
  function_name = "data-processor"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  
  environment {
    variables = {
      DATA_BUCKET = aws_s3_bucket.data.id
    }
  }
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Outputs
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.processor.function_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.data.id
}

output "granted_permissions" {
  description = "S3 permissions granted to Lambda"
  value       = module.lambda_s3_read.granted_permissions
}
