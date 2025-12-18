# Example: ECS Task with Multi-Bucket Access

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

# Multiple S3 buckets for different purposes
resource "aws_s3_bucket" "data" {
  bucket = "example-ecs-data-bucket"
  
  tags = {
    Environment = "production"
    Purpose     = "application-data"
  }
}

resource "aws_s3_bucket" "config" {
  bucket = "example-ecs-config-bucket"
  
  tags = {
    Environment = "production"
    Purpose     = "application-config"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "example-ecs-logs-bucket"
  
  tags = {
    Environment = "production"
    Purpose     = "application-logs"
  }
}

# ECS Task Execution Role (for pulling container images, etc.)
resource "aws_iam_role" "ecs_execution" {
  name = "example-ecs-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (for application permissions)
resource "aws_iam_role" "ecs_task" {
  name = "example-ecs-task-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
  
  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# Grant read/write access to data and config buckets
module "ecs_data_config_access" {
  source = "../"
  
  role_name = aws_iam_role.ecs_task.name
  bucket_arns = [
    aws_s3_bucket.data.arn,
    aws_s3_bucket.config.arn
  ]
  permission_level = "read_write"
  policy_name      = "ecs-data-config-readwrite"
}

# Grant write-only access to logs bucket
module "ecs_logs_access" {
  source = "../"
  
  role_name        = aws_iam_role.ecs_task.name
  bucket_arns      = [aws_s3_bucket.logs.arn]
  permission_level = "write"
  policy_name      = "ecs-logs-write"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "example-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  
  container_definitions = jsonencode([{
    name  = "app"
    image = "nginx:latest"  # Replace with your actual image
    
    environment = [
      {
        name  = "DATA_BUCKET"
        value = aws_s3_bucket.data.id
      },
      {
        name  = "CONFIG_BUCKET"
        value = aws_s3_bucket.config.id
      },
      {
        name  = "LOGS_BUCKET"
        value = aws_s3_bucket.logs.id
      }
    ]
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/example-app"
        "awslogs-region"        = "ap-southeast-2"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
  
  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# Outputs
output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.app.arn
}

output "data_config_permissions" {
  description = "Permissions granted for data and config buckets"
  value       = module.ecs_data_config_access.granted_permissions
}

output "logs_permissions" {
  description = "Permissions granted for logs bucket"
  value       = module.ecs_logs_access.granted_permissions
}

output "s3_buckets" {
  description = "S3 bucket names used by the ECS task"
  value = {
    data   = aws_s3_bucket.data.id
    config = aws_s3_bucket.config.id
    logs   = aws_s3_bucket.logs.id
  }
}
