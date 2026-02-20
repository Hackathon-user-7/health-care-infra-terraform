terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.common_tags,
      {
        Environment = var.environment
        ManagedBy   = "Terraform"
        Project     = var.project_name
      }
    )
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_name                = var.vpc_name
  vpc_cidr                = var.vpc_cidr
  availability_zones      = var.availability_zones
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support
  instance_tenancy        = var.instance_tenancy
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  create_internet_gateway = var.create_internet_gateway
  create_nat_gateway      = var.create_nat_gateway
  nat_gateway_count       = var.nat_gateway_count
  map_public_ip_on_launch = var.map_public_ip_on_launch
  enable_flow_logs        = var.enable_flow_logs
  flow_logs_traffic_type  = var.flow_logs_traffic_type
  flow_logs_retention_days = var.flow_logs_retention_days
  security_groups         = var.security_groups
  network_acls            = var.network_acls
  vpc_endpoints           = var.vpc_endpoints
  tags                    = var.common_tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  roles                          = var.iam_roles
  policies                       = var.iam_policies
  role_policy_attachments        = var.iam_role_policy_attachments
  inline_role_policies           = var.iam_inline_role_policies
  users                          = var.iam_users
  user_policy_attachments        = var.iam_user_policy_attachments
  inline_user_policies           = var.iam_inline_user_policies
  user_access_keys               = var.iam_user_access_keys
  groups                         = var.iam_groups
  group_policy_attachments       = var.iam_group_policy_attachments
  user_group_memberships         = var.iam_user_group_memberships
  instance_profiles              = var.iam_instance_profiles
  cross_account_roles            = var.iam_cross_account_roles
  cross_account_role_policies    = var.iam_cross_account_role_policies
  tags                           = var.common_tags
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  for_each = var.ecr_repositories

  repository_name       = each.value.repository_name
  image_tag_mutability  = each.value.image_tag_mutability
  scan_on_push          = each.value.scan_on_push
  encryption_type       = each.value.encryption_type
  kms_key               = each.value.kms_key
  force_delete          = each.value.force_delete
  lifecycle_policy      = each.value.lifecycle_policy
  create_repository_policy = each.value.create_repository_policy
  repository_policy     = each.value.repository_policy
  tags                  = var.common_tags
}

# S3 Module
module "s3" {
  source = "./modules/s3"

  buckets       = var.s3_buckets
  bucket_metrics = var.s3_bucket_metrics
  objects       = var.s3_objects
  tags          = var.common_tags
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  for_each = var.ecs_services

  cluster_name                               = each.value.cluster_name
  service_name                               = each.value.service_name
  task_family                                = each.value.task_family
  container_name                             = each.value.container_name
  container_image                            = each.value.container_image
  container_cpu                              = each.value.container_cpu
  container_memory                           = each.value.container_memory
  task_cpu                                   = each.value.task_cpu
  task_memory                                = each.value.task_memory
  network_mode                               = each.value.network_mode
  requires_compatibilities                   = each.value.requires_compatibilities
  launch_type                                = each.value.launch_type
  platform_version                           = each.value.platform_version
  desired_count                              = each.value.desired_count
  deployment_minimum_healthy_percent         = each.value.deployment_minimum_healthy_percent
  deployment_maximum_percent                 = each.value.deployment_maximum_percent
  scheduling_strategy                        = each.value.scheduling_strategy
  subnets                                    = each.value.subnets
  security_groups                            = each.value.security_groups
  assign_public_ip                           = each.value.assign_public_ip
  port_mappings                              = each.value.port_mappings
  environment_variables                      = each.value.environment_variables
  secrets                                    = each.value.secrets
  log_configuration                          = each.value.log_configuration
  health_check                               = each.value.health_check
  load_balancers                             = each.value.load_balancers
  service_registries                         = each.value.service_registries
  task_role_arn                              = each.value.task_role_arn
  enable_autoscaling                         = each.value.enable_autoscaling
  autoscaling_min_capacity                   = each.value.autoscaling_min_capacity
  autoscaling_max_capacity                   = each.value.autoscaling_max_capacity
  autoscaling_cpu_target                     = each.value.autoscaling_cpu_target
  autoscaling_memory_target                  = each.value.autoscaling_memory_target
  capacity_providers                         = each.value.capacity_providers
  default_capacity_provider                  = each.value.default_capacity_provider
  default_capacity_base                      = each.value.default_capacity_base
  default_capacity_weight                    = each.value.default_capacity_weight
  enable_container_insights                  = each.value.enable_container_insights
  tags                                       = var.common_tags

  depends_on = [module.vpc]
}
