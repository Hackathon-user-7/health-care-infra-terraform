# VPC Module Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IP addresses"
  value       = module.vpc.nat_gateway_public_ips
}

output "security_group_ids" {
  description = "Map of security group IDs"
  value       = module.vpc.security_group_ids
}

output "vpc_flow_logs_id" {
  description = "VPC Flow Logs ID"
  value       = module.vpc.vpc_flow_logs_id
}

# IAM Module Outputs
output "iam_roles" {
  description = "Map of IAM roles created"
  value       = module.iam.roles
  sensitive   = true
}

output "iam_policies" {
  description = "Map of IAM policies created"
  value       = module.iam.policies
}

output "iam_users" {
  description = "Map of IAM users created"
  value       = module.iam.users
  sensitive   = true
}

output "iam_groups" {
  description = "Map of IAM groups created"
  value       = module.iam.groups
}

output "iam_instance_profiles" {
  description = "Map of IAM instance profiles created"
  value       = module.iam.instance_profiles
}

output "iam_user_access_keys" {
  description = "Map of IAM user access keys"
  value       = module.iam.user_access_keys
  sensitive   = true
}

# ECR Module Outputs
output "ecr_repositories" {
  description = "Map of ECR repository information"
  value = {
    for k, v in module.ecr : k => {
      repository_url = v.repository_url
      repository_arn = v.repository_arn
      registry_id    = v.registry_id
      repository_name = v.repository_name
    }
  }
}

output "ecr_repository_urls" {
  description = "Map of ECR repository URLs"
  value = {
    for k, v in module.ecr : k => v.repository_url
  }
}

# S3 Module Outputs
output "s3_bucket_ids" {
  description = "Map of S3 bucket IDs"
  value       = module.s3.bucket_ids
}

output "s3_bucket_arns" {
  description = "Map of S3 bucket ARNs"
  value       = module.s3.bucket_arns
}

output "s3_bucket_domain_names" {
  description = "Map of S3 bucket domain names"
  value       = module.s3.bucket_domain_names
}

output "s3_bucket_regional_domain_names" {
  description = "Map of S3 bucket regional domain names"
  value       = module.s3.bucket_regional_domain_names
}

# ECS Module Outputs
output "ecs_clusters" {
  description = "Map of ECS cluster information"
  value = {
    for k, v in module.ecs : k => {
      cluster_id   = v.cluster_id
      cluster_arn  = v.cluster_arn
      cluster_name = v.cluster_name
    }
  }
}

output "ecs_services" {
  description = "Map of ECS service information"
  value = {
    for k, v in module.ecs : k => {
      service_id   = v.service_id
      service_arn  = v.service_arn
      service_name = v.service_name
    }
  }
}

output "ecs_task_definitions" {
  description = "Map of ECS task definition information"
  value = {
    for k, v in module.ecs : k => {
      task_definition_arn = v.task_definition_arn
      task_definition_family = v.task_definition_family
      task_definition_revision = v.task_definition_revision
    }
  }
}

output "ecs_task_execution_roles" {
  description = "Map of ECS task execution role ARNs"
  value = {
    for k, v in module.ecs : k => v.task_execution_role_arn
  }
}

output "ecs_task_roles" {
  description = "Map of ECS task role ARNs"
  value = {
    for k, v in module.ecs : k => v.task_role_arn
  }
}

# Summary Outputs
output "infrastructure_summary" {
  description = "Summary of created infrastructure"
  value = {
    vpc_id             = module.vpc.vpc_id
    public_subnets    = length(module.vpc.public_subnet_ids)
    private_subnets   = length(module.vpc.private_subnet_ids)
    ecr_repositories  = length(module.ecr)
    s3_buckets        = length(module.s3.bucket_ids)
    ecs_services      = length(module.ecs)
    iam_roles         = length(module.iam.roles)
    iam_users         = length(module.iam.users)
    iam_groups        = length(module.iam.groups)
  }
}
