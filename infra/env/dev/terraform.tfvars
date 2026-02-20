aws_region = "us-east-1"
environment = "dev"
project_name = "healthcare-microservice"

# Common Tags
common_tags = {
  Environment = "dev"
  Project     = "healthcare-microservice"
  ManagedBy   = "Terraform"
  CostCenter  = "Healthcare"
  CreatedDate = "2026-02-20"
}

# VPC Configuration
vpc_name                = "healthcare-vpc-dev"
vpc_cidr                = "10.0.0.0/16"
availability_zones      = ["us-east-1a", "us-east-1b"]
enable_dns_hostnames    = true
enable_dns_support      = true
instance_tenancy        = "default"
public_subnet_cidrs     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs    = ["10.0.11.0/24", "10.0.12.0/24"]
create_internet_gateway = true
create_nat_gateway      = true
nat_gateway_count       = 1
map_public_ip_on_launch = true
enable_flow_logs        = true
flow_logs_traffic_type  = "ALL"
flow_logs_retention_days = 7

# Security Groups
security_groups = {
  alb = {
    name        = "healthcare-alb-sg-dev"
    description = "Security group for ALB"
    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP from anywhere"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTPS from anywhere"
      }
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 65535
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound"
      }
    ]
  }
  ecs = {
    name        = "healthcare-ecs-sg-dev"
    description = "Security group for ECS tasks"
    ingress_rules = [
      {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
        description = "Allow ECS from VPC"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
        description = "Allow HTTPS from VPC"
      }
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 65535
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound"
      }
    ]
  }
  rds = {
    name        = "healthcare-rds-sg-dev"
    description = "Security group for RDS database"
    ingress_rules = [
      {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
        description = "Allow PostgreSQL from VPC"
      }
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 65535
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound"
      }
    ]
  }
}

# IAM Configuration
iam_roles = {
  ecs_task_role = {
    name        = "healthcare-ecs-task-role-dev"
    description = "Role for ECS task execution"
    assume_role_policy = {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          }
        }
      ]
    }
  }
  lambda_role = {
    name        = "healthcare-lambda-role-dev"
    description = "Role for Lambda functions"
    assume_role_policy = {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        }
      ]
    }
  }
}

iam_policies = {
  s3_access = {
    name        = "healthcare-s3-access-policy-dev"
    description = "Policy for S3 bucket access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:s3:::healthcare-*-dev/*"
        }
      ]
    })
  }
  ecr_access = {
    name        = "healthcare-ecr-access-policy-dev"
    description = "Policy for ECR access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchGetImage",
            "ecr:GetDownloadUrlForLayer"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

iam_role_policy_attachments = {
  ecs_ecr_policy = {
    role_name   = "ecs_task_role"
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
  ecs_cloudwatch_policy = {
    role_name   = "ecs_task_role"
    policy_arn  = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  }
}

# ECR Configuration
ecr_repositories = {
  api_service = {
    repository_name      = "healthcare-api-service-dev"
    image_tag_mutability = "MUTABLE"
    scan_on_push         = true
    encryption_type      = "AES256"
    force_delete         = true
  }
  notification_service = {
    repository_name      = "healthcare-notification-service-dev"
    image_tag_mutability = "MUTABLE"
    scan_on_push         = true
    encryption_type      = "AES256"
    force_delete         = true
  }
  web_ui = {
    repository_name      = "healthcare-web-ui-dev"
    image_tag_mutability = "MUTABLE"
    scan_on_push         = true
    encryption_type      = "AES256"
    force_delete         = true
  }
}

# S3 Configuration
s3_buckets = {
  application_data = {
    name                = "healthcare-app-data-dev"
    force_destroy       = true
    enable_versioning   = true
    enable_sse          = true
    sse_algorithm       = "AES256"
    block_public_access = true
  }
  logs = {
    name                = "healthcare-logs-dev"
    force_destroy       = true
    enable_versioning   = true
    enable_sse          = true
    sse_algorithm       = "AES256"
    block_public_access = true
    lifecycle_rules = [
      {
        id      = "delete-old-logs"
        enabled = true
        filter  = {
          prefix = "logs/"
        }
        expiration = {
          days = 30
        }
      }
    ]
  }
  backups = {
    name                = "healthcare-backups-dev"
    force_destroy       = false
    enable_versioning   = true
    enable_sse          = true
    sse_algorithm       = "AES256"
    block_public_access = true
    lifecycle_rules = [
      {
        id      = "transition-to-glacier"
        enabled = true
        transitions = [
          {
            days          = 90
            storage_class = "GLACIER"
          }
        ]
      }
    ]
  }
}

# ECS Configuration
ecs_services = {
  api_service = {
    cluster_name      = "healthcare-cluster-dev"
    service_name      = "healthcare-api-service-dev"
    task_family       = "healthcare-api-service-dev"
    container_name    = "api-service"
    container_image   = "healthcare-api-service-dev:latest"
    task_cpu          = "256"
    task_memory       = "512"
    container_cpu     = 256
    container_memory  = 512
    desired_count     = 1
    enable_autoscaling = false
    subnets           = [] # Will be populated from VPC module
    security_groups   = [] # Will be populated from VPC module
    port_mappings = [
      {
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }
    ]
    environment_variables = [
      {
        name  = "ENVIRONMENT"
        value = "dev"
      },
      {
        name  = "LOG_LEVEL"
        value = "DEBUG"
      }
    ]
    log_configuration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/healthcare-api-service-dev"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
    enable_container_insights = true
  }
  notification_service = {
    cluster_name      = "healthcare-cluster-dev"
    service_name      = "healthcare-notification-service-dev"
    task_family       = "healthcare-notification-service-dev"
    container_name    = "notification-service"
    container_image   = "healthcare-notification-service-dev:latest"
    task_cpu          = "256"
    task_memory       = "512"
    container_cpu     = 256
    container_memory  = 512
    desired_count     = 1
    enable_autoscaling = false
    subnets           = [] # Will be populated from VPC module
    security_groups   = [] # Will be populated from VPC module
    port_mappings = [
      {
        containerPort = 8081
        hostPort      = 8081
        protocol      = "tcp"
      }
    ]
    environment_variables = [
      {
        name  = "ENVIRONMENT"
        value = "dev"
      },
      {
        name  = "LOG_LEVEL"
        value = "DEBUG"
      }
    ]
    log_configuration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/healthcare-notification-service-dev"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
    enable_container_insights = true
  }
}
