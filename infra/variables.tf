# AWS Provider Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    "Created"   = "Terraform"
    "CostCenter" = "Healthcare"
  }
}

# VPC Variables
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "healthcare-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "Instance tenancy for the VPC"
  type        = string
  default     = "default"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "create_internet_gateway" {
  description = "Create Internet Gateway for the VPC"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Create NAT Gateway for the VPC"
  type        = bool
  default     = true
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create"
  type        = number
  default     = 2
}

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IP addresses to instances in public subnets"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_traffic_type" {
  description = "Type of traffic to log (ACCEPT, REJECT, ALL)"
  type        = string
  default     = "ALL"
}

variable "flow_logs_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 30
}

variable "security_groups" {
  description = "Map of security groups to create"
  type = map(object({
    name        = string
    description = string
    ingress_rules = list(object({
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      description      = optional(string, "")
    }))
    egress_rules = list(object({
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string), ["0.0.0.0/0"])
      ipv6_cidr_blocks = optional(list(string), [])
      description      = optional(string, "")
    }))
  }))
  default = {}
}

variable "network_acls" {
  description = "Map of network ACLs to create"
  type = map(object({
    name       = string
    subnet_ids = optional(list(string), [])
  }))
  default = {}
}

variable "vpc_endpoints" {
  description = "Map of VPC endpoints to create"
  type = map(object({
    name                = string
    service_name        = string
    vpc_endpoint_type   = optional(string, "Gateway")
    subnet_ids          = optional(list(string), [])
    security_group_ids  = optional(list(string), [])
    private_dns_enabled = optional(bool, false)
  }))
  default = {}
}

# IAM Variables
variable "iam_roles" {
  description = "Map of IAM roles to create"
  type = map(object({
    name                  = string
    description           = optional(string, "")
    assume_role_policy    = object({})
    max_session_duration  = optional(number, 3600)
  }))
  default = {}
}

variable "iam_policies" {
  description = "Map of IAM policies to create"
  type = map(object({
    name        = string
    description = optional(string, "")
    policy      = string
  }))
  default = {}
}

variable "iam_role_policy_attachments" {
  description = "Map of policy attachments to roles"
  type = map(object({
    role_name   = string
    policy_name = optional(string)
    policy_arn  = optional(string)
  }))
  default = {}
}

variable "iam_inline_role_policies" {
  description = "Map of inline policies to attach to roles"
  type = map(object({
    name      = string
    role_name = string
    policy    = object({})
  }))
  default = {}
}

variable "iam_users" {
  description = "Map of IAM users to create"
  type = map(object({
    name                 = string
    path                 = optional(string, "/")
    force_destroy        = optional(bool, false)
    permissions_boundary = optional(string)
  }))
  default = {}
}

variable "iam_user_policy_attachments" {
  description = "Map of policy attachments to users"
  type = map(object({
    user_name   = string
    policy_name = optional(string)
    policy_arn  = optional(string)
  }))
  default = {}
}

variable "iam_inline_user_policies" {
  description = "Map of inline policies to attach to users"
  type = map(object({
    name      = string
    user_name = string
    policy    = object({})
  }))
  default = {}
}

variable "iam_user_access_keys" {
  description = "Map of users for which to create access keys"
  type = map(object({
    user_name = string
  }))
  default = {}
}

variable "iam_groups" {
  description = "Map of IAM groups to create"
  type = map(object({
    name = string
    path = optional(string, "/")
  }))
  default = {}
}

variable "iam_group_policy_attachments" {
  description = "Map of policy attachments to groups"
  type = map(object({
    group_name  = string
    policy_name = optional(string)
    policy_arn  = optional(string)
  }))
  default = {}
}

variable "iam_user_group_memberships" {
  description = "Map of user group memberships"
  type = map(object({
    user_name  = string
    group_names = list(string)
  }))
  default = {}
}

variable "iam_instance_profiles" {
  description = "Map of IAM instance profiles to create"
  type = map(object({
    name      = string
    role_name = string
  }))
  default = {}
}

variable "iam_cross_account_roles" {
  description = "Map of cross-account IAM roles"
  type = map(object({
    name               = string
    description        = optional(string, "")
    assume_role_policy = object({})
  }))
  default = {}
}

variable "iam_cross_account_role_policies" {
  description = "Map of policy attachments to cross-account roles"
  type = map(object({
    role_name   = string
    policy_name = optional(string)
    policy_arn  = optional(string)
  }))
  default = {}
}

# ECR Variables
variable "ecr_repositories" {
  description = "Map of ECR repositories to create"
  type = map(object({
    repository_name         = string
    image_tag_mutability    = optional(string, "MUTABLE")
    scan_on_push            = optional(bool, true)
    encryption_type         = optional(string, "AES256")
    kms_key                 = optional(string)
    force_delete            = optional(bool, false)
    lifecycle_policy        = optional(string)
    create_repository_policy = optional(bool, false)
    repository_policy       = optional(string)
  }))
  default = {}
}

# S3 Variables
variable "s3_buckets" {
  description = "Map of S3 buckets to create"
  type = map(object({
    name                  = string
    force_destroy         = optional(bool, false)
    object_lock_enabled   = optional(bool, false)
    enable_versioning     = optional(bool, true)
    mfa_delete            = optional(bool, false)
    enable_sse            = optional(bool, true)
    sse_algorithm         = optional(string, "AES256")
    kms_key_id            = optional(string)
    bucket_key_enabled    = optional(bool, true)
    block_public_access   = optional(bool, true)
    acl                   = optional(string)
    bucket_policy         = optional(string)
    cors_rules            = optional(list(object({
      allowed_headers = optional(list(string), [])
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = optional(list(string), [])
      max_age_seconds = optional(number, 3000)
    })), [])
    lifecycle_rules = optional(list(object({
      id      = string
      enabled = optional(bool, true)
      filter = optional(object({
        prefix                    = optional(string)
        object_size_greater_than  = optional(number)
        object_size_less_than     = optional(number)
        and = optional(object({
          prefix                    = optional(string)
          tags                      = optional(map(string))
          object_size_greater_than  = optional(number)
          object_size_less_than     = optional(number)
        }))
      }))
      expiration = optional(object({
        date                         = optional(string)
        days                         = optional(number)
        expired_object_delete_marker = optional(bool)
      }))
      noncurrent_version_expiration = optional(object({
        noncurrent_days = optional(number)
      }))
      transitions = optional(list(object({
        date          = optional(string)
        days          = optional(number)
        storage_class = string
      })), [])
      noncurrent_version_transitions = optional(list(object({
        noncurrent_days = number
        storage_class   = string
      })), [])
    })), [])
    logging_configuration = optional(object({
      target_bucket = string
      target_prefix = optional(string, "")
    }))
    replication_configuration = optional(object({
      role_arn = string
      rules = list(object({
        id       = string
        enabled  = optional(bool, true)
        priority = number
        filter = object({
          prefix = optional(string, "")
        })
        destination = object({
          bucket_arn                    = string
          storage_class                 = optional(string, "STANDARD")
          enable_replication_time       = optional(bool, false)
          replication_time_minutes      = optional(number, 15)
          enable_metrics                = optional(bool, false)
          metrics_minutes               = optional(number, 15)
        })
      }))
    }))
  }))
  default = {}
}

variable "s3_bucket_metrics" {
  description = "Map of S3 bucket metrics configurations"
  type = map(object({
    bucket_key = string
    name       = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
  }))
  default = {}
}

variable "s3_objects" {
  description = "Map of S3 objects to upload"
  type = map(object({
    bucket_key   = string
    key          = string
    source       = optional(string)
    content      = optional(string)
    content_type = optional(string, "application/octet-stream")
    acl          = optional(string, "private")
    cache_control = optional(string)
    metadata     = optional(map(string), {})
  }))
  default = {}
}

# ECS Variables
variable "ecs_services" {
  description = "Map of ECS services to create"
  type = map(object({
    cluster_name                          = string
    service_name                          = string
    task_family                           = string
    container_name                        = string
    container_image                       = string
    container_cpu                         = optional(number, 256)
    container_memory                      = optional(number, 512)
    task_cpu                              = string
    task_memory                           = string
    network_mode                          = optional(string, "awsvpc")
    requires_compatibilities              = optional(list(string), ["FARGATE"])
    launch_type                           = optional(string, "FARGATE")
    platform_version                      = optional(string, "LATEST")
    desired_count                         = optional(number, 1)
    deployment_minimum_healthy_percent    = optional(number, 100)
    deployment_maximum_percent            = optional(number, 200)
    scheduling_strategy                   = optional(string, "REPLICA")
    subnets                               = list(string)
    security_groups                       = list(string)
    assign_public_ip                      = optional(bool, false)
    port_mappings = optional(list(object({
      containerPort = number
      hostPort      = number
      protocol      = optional(string, "tcp")
    })), [
      {
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }
    ])
    environment_variables = optional(list(object({
      name  = string
      value = string
    })), [])
    secrets = optional(list(object({
      name      = string
      valueFrom = string
    })), [])
    log_configuration = optional(object({
      logDriver = string
      options   = map(string)
    }), {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/default"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    })
    health_check = optional(object({
      command      = list(string)
      interval     = number
      timeout      = number
      retries      = number
      startPeriod  = optional(number)
    }), null)
    load_balancers = optional(list(object({
      target_group_arn = string
      container_name   = string
      container_port   = number
    })), [])
    service_registries = optional(list(object({
      registry_arn = string
      port         = optional(number)
    })), [])
    task_role_arn                    = optional(string)
    enable_autoscaling               = optional(bool, false)
    autoscaling_min_capacity         = optional(number, 1)
    autoscaling_max_capacity         = optional(number, 4)
    autoscaling_cpu_target           = optional(number, 70)
    autoscaling_memory_target        = optional(number, 80)
    capacity_providers               = optional(list(string), ["FARGATE", "FARGATE_SPOT"])
    default_capacity_provider        = optional(string, "FARGATE")
    default_capacity_base            = optional(number, 1)
    default_capacity_weight          = optional(number, 100)
    enable_container_insights        = optional(bool, true)
  }))
  default = {}
}
