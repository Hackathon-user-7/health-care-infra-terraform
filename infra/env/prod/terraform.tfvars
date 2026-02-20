aws_region = "us-east-1"
environment = "prod"
project_name = "healthcare-microservice"

# Common Tags
common_tags = {
  Environment = "prod"
  Project     = "healthcare-microservice"
  ManagedBy   = "Terraform"
  CostCenter  = "Healthcare"
  CreatedDate = "2026-02-20"
}

# VPC Configuration
vpc_name                = "healthcare-vpc-prod"
vpc_cidr                = "10.1.0.0/16"
availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
enable_dns_hostnames    = true
enable_dns_support      = true
instance_tenancy        = "default"
public_subnet_cidrs     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnet_cidrs    = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
create_internet_gateway = true
create_nat_gateway      = true
nat_gateway_count       = 3
map_public_ip_on_launch = false
enable_flow_logs        = true
flow_logs_traffic_type  = "ALL"
flow_logs_retention_days = 90

# Security Groups
security_groups = {
  alb = {
    name        = "healthcare-alb-sg-prod"
    description = "Security group for ALB - Production"
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
    name        = "healthcare-ecs-sg-prod"
    description = "Security group for ECS tasks - Production"
    ingress_rules = [
      {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["10.1.0.0/16"]
        description = "Allow ECS from VPC"
      },
      {
        from_port   = 8081
        to_port     = 8081
        protocol    = "tcp"
        cidr_blocks = ["10.1.0.0/16"]
        description = "Allow notification service from VPC"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["10.1.0.0/16"]
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
    name        = "healthcare-rds-sg-prod"
    description = "Security group for RDS database - Production"
    ingress_rules = [
      {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = ["10.1.0.0/16"]
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
    name        = "healthcare-ecs-task-role-prod"
    description = "Role for ECS task execution - Production"
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
    max_session_duration = 3600
  }
  lambda_role = {
    name        = "healthcare-lambda-role-prod"
    description = "Role for Lambda functions - Production"
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
  backup_role = {
    name        = "healthcare-backup-role-prod"
    description = "Role for backup operations - Production"
    assume_role_policy = {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "backup.amazonaws.com"
          }
        }
      ]
    }
  }
}

iam_policies = {
  s3_access = {
    name        = "healthcare-s3-access-policy-prod"
    description = "Policy for S3 bucket access - Production"
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
          Resource = "arn:aws:s3:::healthcare-*-prod/*"
        }
      ]
    })
  }
  ecr_access = {
    name        = "healthcare-ecr-access-policy-prod"
    description = "Policy for ECR access - Production"
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
  secrets_access = {
    name        = "healthcare-secrets-access-policy-prod"
    description = "Policy for Secrets Manager access - Production"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:secretsmanager:us-east-1:*:secret:healthcare/*"
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
    repository_name       = "healthcare-api-service-prod"
    image_tag_mutability  = "IMMUTABLE"
    scan_on_push          = true
    encryption_type       = "AES256"
    force_delete          = false
    create_repository_policy = true
    repository_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Action = "ecr:*"
          Condition = {
            StringEquals = {
              "aws:PrincipalAccount" = "123456789012"
            }
          }
        }
      ]
    })
  }
  notification_service = {
    repository_name       = "healthcare-notification-service-prod"
    image_tag_mutability  = "IMMUTABLE"
    scan_on_push          = true
    encryption_type       = "AES256"
    force_delete          = false
  }
  web_ui = {
    repository_name       = "healthcare-web-ui-prod"
    image_tag_mutability  = "IMMUTABLE"
    scan_on_push          = true
    encryption_type       = "AES256"
    force_delete          = false
  }
}

# S3 Configuration
s3_buckets = {
  application_data = {
    name                  = "healthcare-app-data-prod"
    force_destroy         = false
    enable_versioning     = true
    mfa_delete            = false
    enable_sse            = true
    sse_algorithm         = "AES256"
    block_public_access   = true
    lifecycle_rules = [
      {
        id      = "archive-old-data"
        enabled = true
        transitions = [
          {
            days          = 180
            storage_class = "GLACIER"
          }
        ]
      }
    ]
  }
  logs = {
    name                  = "healthcare-logs-prod"
    force_destroy         = false
    enable_versioning     = true
    mfa_delete            = false
    enable_sse            = true
    sse_algorithm         = "AES256"
    block_public_access   = true
    lifecycle_rules = [
      {
        id      = "delete-old-logs"
        enabled = true
        filter  = {
          prefix = "logs/"
        }
        expiration = {
          days = 90
        }
      },
      {
        id      = "transition-to-glacier"
        enabled = true
        transitions = [
          {
            days          = 30
            storage_class = "GLACIER"
          }
        ]
      }
    ]
  }
  backups = {
    name                  = "healthcare-backups-prod"
    force_destroy         = false
    enable_versioning     = true
    mfa_delete            = false
    enable_sse            = true
    sse_algorithm         = "AES256"
    block_public_access   = true
    lifecycle_rules = [
      {
        id      = "transition-to-deep-archive"
        enabled = true
        transitions = [
          {
            days          = 90
            storage_class = "DEEP_ARCHIVE"
          }
        ]
      }
    ]
  }
}

# ECS Configuration
ecs_services = {
  api_service = {
    cluster_name                        = "healthcare-cluster-prod"
    service_name                        = "healthcare-api-service-prod"
    task_family                         = "healthcare-api-service-prod"
    container_name                      = "api-service"
    container_image                     = "healthcare-api-service-prod:latest"
    task_cpu                            = "512"
    task_memory                         = "1024"
    container_cpu                       = 512
    container_memory                    = 1024
    desired_count                       = 3
    deployment_minimum_healthy_percent  = 100
    deployment_maximum_percent          = 200
    enable_autoscaling                  = true
    autoscaling_min_capacity            = 3
    autoscaling_max_capacity            = 10
    autoscaling_cpu_target              = 70
    autoscaling_memory_target           = 80
    subnets                             = [] # Will be populated from VPC module
    security_groups                     = [] # Will be populated from VPC module
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
        value = "prod"
      },
      {
        name  = "LOG_LEVEL"
        value = "INFO"
      }
    ]
    log_configuration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/healthcare-api-service-prod"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
    enable_container_insights = true
  }
  notification_service = {
    cluster_name                        = "healthcare-cluster-prod"
    service_name                        = "healthcare-notification-service-prod"
    task_family                         = "healthcare-notification-service-prod"
    container_name                      = "notification-service"
    container_image                     = "healthcare-notification-service-prod:latest"
    task_cpu                            = "256"
    task_memory                         = "512"
    container_cpu                       = 256
    container_memory                    = 512
    desired_count                       = 2
    deployment_minimum_healthy_percent  = 100
    deployment_maximum_percent          = 200
    enable_autoscaling                  = true
    autoscaling_min_capacity            = 2
    autoscaling_max_capacity            = 6
    autoscaling_cpu_target              = 70
    autoscaling_memory_target           = 80
    subnets                             = [] # Will be populated from VPC module
    security_groups                     = [] # Will be populated from VPC module
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
        value = "prod"
      },
      {
        name  = "LOG_LEVEL"
        value = "WARN"
      }
    ]
    log_configuration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/healthcare-notification-service-prod"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
    enable_container_insights = true
  }
}
