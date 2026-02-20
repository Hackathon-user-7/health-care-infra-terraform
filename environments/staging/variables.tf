variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "container_image" {
  description = "Docker image for ECS task"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port on which container listens"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}