variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "task_family" {
  description = "Name of the task definition family"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image URI for the container"
  type        = string
}

variable "container_cpu" {
  description = "CPU units for the container (256, 512, 1024, etc.)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory in MB for the container"
  type        = number
  default     = 512
}

variable "task_cpu" {
  description = "CPU units for the task (256, 512, 1024, 2048, etc.)"
  type        = string
}

variable "task_memory" {
  description = "Memory in MB for the task"
  type        = string
}

variable "network_mode" {
  description = "Docker networking mode (awsvpc, bridge, host, none)"
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "Set of launch types required to run the task"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "launch_type" {
  description = "Launch type for the service (FARGATE, EC2, EXTERNAL)"
  type        = string
  default     = "FARGATE"
}

variable "platform_version" {
  description = "Platform version for Fargate"
  type        = string
  default     = "LATEST"
}

variable "desired_count" {
  description = "Number of instances to run"
  type        = number
  default     = 1
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percentage of tasks to maintain during deployment"
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "Maximum percentage of tasks allowed during deployment"
  type        = number
  default     = 200
}

variable "scheduling_strategy" {
  description = "Scheduling strategy (REPLICA or DAEMON)"
  type        = string
  default     = "REPLICA"
}

variable "subnets" {
  description = "List of subnet IDs for the service"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Assign public IP to tasks"
  type        = bool
  default     = false
}

variable "port_mappings" {
  description = "Port mappings for the container"
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = optional(string, "tcp")
  }))
  default = [
    {
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    }
  ]
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "Secrets from AWS Secrets Manager or Parameter Store"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "log_configuration" {
  description = "Log configuration for the container"
  type = object({
    logDriver = string
    options   = map(string)
  })
  default = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = "/ecs/default"
      "awslogs-region"        = "us-east-1"
      "awslogs-stream-prefix" = "ecs"
    }
  }
}

variable "health_check" {
  description = "Health check configuration"
  type = object({
    command      = list(string)
    interval     = number
    timeout      = number
    retries      = number
    startPeriod  = optional(number)
  })
  default = null
}

variable "load_balancers" {
  description = "Load balancer configuration"
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}

variable "service_registries" {
  description = "Service registry configuration (for service discovery)"
  type = list(object({
    registry_arn = string
    port         = optional(number)
  }))
  default = []
}

variable "task_role_arn" {
  description = "ARN of the IAM role for ECS tasks"
  type        = string
  default     = null
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for the service"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for autoscaling"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks for autoscaling"
  type        = number
  default     = 4
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for autoscaling"
  type        = number
  default     = 70
}

variable "autoscaling_memory_target" {
  description = "Target memory utilization percentage for autoscaling"
  type        = number
  default     = 80
}

variable "capacity_providers" {
  description = "Capacity providers for the cluster"
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider" {
  description = "Default capacity provider for the cluster"
  type        = string
  default     = "FARGATE"
}

variable "default_capacity_base" {
  description = "Base number of tasks to run on the default capacity provider"
  type        = number
  default     = 1
}

variable "default_capacity_weight" {
  description = "Weight of the default capacity provider"
  type        = number
  default     = 100
}

variable "enable_container_insights" {
  description = "Enable Container Insights for the cluster"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
