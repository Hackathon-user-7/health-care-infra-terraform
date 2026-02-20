variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
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
  validation {
    condition     = contains(["default", "dedicated", "host"], var.instance_tenancy)
    error_message = "Instance tenancy must be default, dedicated, or host."
  }
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = []
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
  default     = 1
  validation {
    condition     = var.nat_gateway_count > 0 && var.nat_gateway_count <= 3
    error_message = "NAT Gateway count must be between 1 and 3."
  }
}

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IP addresses to instances in public subnets"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_logs_traffic_type" {
  description = "Type of traffic to log (ACCEPT, REJECT, ALL)"
  type        = string
  default     = "ALL"
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_logs_traffic_type)
    error_message = "Flow logs traffic type must be ACCEPT, REJECT, or ALL."
  }
}

variable "flow_logs_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 7
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
  default = {
    default = {
      name        = "default"
      description = "Default security group"
      ingress_rules = [
        {
          from_port   = 0
          to_port     = 65535
          protocol    = "-1"
          cidr_blocks = []
          description = "Allow all from VPC"
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

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
