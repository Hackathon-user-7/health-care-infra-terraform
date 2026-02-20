# Development Environment Backend Configuration
# Usage: terraform init -backend-config=./env/dev/backend.tf
terraform {
  backend "s3" {
    bucket         = "healthcare-terraform-state-user7/dev"
    key            = "healthcare-microservice/dev/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    use_lockfile   = true 
    
  }
}

