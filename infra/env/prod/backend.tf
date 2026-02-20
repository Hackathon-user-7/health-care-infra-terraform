# Production Environment Backend Configuration
# Usage: terraform init -backend-config=./env/prod/backend.conf

bucket         = "healthcare-terraform-state-prod"
key            = "healthcare-microservice/prod/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-locks"
