# Multi-Environment Setup

## Structure
```
environments/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── staging/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars
```

## Environment Differences
- **Dev**: VPC CIDR 10.0.0.0/16
- **Staging**: VPC CIDR 10.1.0.0/16  
- **Prod**: VPC CIDR 10.2.0.0/16

## Usage

### Deploy Dev Environment
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Deploy Staging Environment
```bash
cd environments/staging
terraform init
terraform plan
terraform apply
```

### Deploy Prod Environment
```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

## State Management
Each environment uses separate state files in S3:
- Dev: `dev/terraform.tfstate`
- Staging: `staging/terraform.tfstate`
- Prod: `prod/terraform.tfstate`