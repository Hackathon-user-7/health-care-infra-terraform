output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = aws_vpc.main.arn
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = try(aws_internet_gateway.main[0].id, null)
}

output "internet_gateway_arn" {
  description = "Internet Gateway ARN"
  value       = try(aws_internet_gateway.main[0].arn, null)
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = [for ng in aws_nat_gateway.main : ng.id]
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IP addresses"
  value       = [for eip in aws_eip.nat : eip.public_ip]
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = [for subnet in aws_subnet.public : subnet.cidr_block]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = [for subnet in aws_subnet.private : subnet.cidr_block]
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = try(aws_route_table.public[0].id, null)
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = [for rt in aws_route_table.private : rt.id]
}

output "security_group_ids" {
  description = "Map of security group IDs"
  value = {
    for k, sg in aws_security_group.main : k => sg.id
  }
}

output "security_group_names" {
  description = "Map of security group names"
  value = {
    for k, sg in aws_security_group.main : k => sg.name
  }
}

output "security_group_arns" {
  description = "Map of security group ARNs"
  value = {
    for k, sg in aws_security_group.main : k => sg.arn
  }
}

output "vpc_flow_logs_id" {
  description = "VPC Flow Logs ID"
  value       = try(aws_flow_log.main[0].id, null)
}

output "vpc_flow_logs_log_group" {
  description = "CloudWatch Log Group name for VPC Flow Logs"
  value       = try(aws_cloudwatch_log_group.vpc_flow_logs[0].name, null)
}

output "vpc_endpoint_ids" {
  description = "Map of VPC endpoint IDs"
  value = {
    for k, endpoint in aws_vpc_endpoint.main : k => endpoint.id
  }
}

output "network_acl_ids" {
  description = "Map of Network ACL IDs"
  value = {
    for k, nacl in aws_network_acl.main : k => nacl.id
  }
}

output "public_subnets_map" {
  description = "Map of public subnet information"
  value = {
    for i, subnet in aws_subnet.public : "public-subnet-${i + 1}" => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
    }
  }
}

output "private_subnets_map" {
  description = "Map of private subnet information"
  value = {
    for i, subnet in aws_subnet.private : "private-subnet-${i + 1}" => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
    }
  }
}

output "all_subnet_ids" {
  description = "List of all subnet IDs"
  value       = concat([for subnet in aws_subnet.public : subnet.id], [for subnet in aws_subnet.private : subnet.id])
}

output "all_subnet_cidrs" {
  description = "List of all subnet CIDR blocks"
  value       = concat([for subnet in aws_subnet.public : subnet.cidr_block], [for subnet in aws_subnet.private : subnet.cidr_block])
}
