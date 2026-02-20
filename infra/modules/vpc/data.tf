data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# Get available AZs for the region
data "aws_availability_zones" "available" {
  state = "available"
}
