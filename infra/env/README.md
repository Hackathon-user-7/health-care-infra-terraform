# Healthcare Microservice Infrastructure - Environment Configuration Guide

This directory contains environment-specific Terraform configurations for dev and prod environments.

## Directory Structure

```
env/
├── dev/
│   ├── terraform.tfvars      # Dev environment variables
│   └── backend.conf          # Dev state backend configuration
└── prod/
    ├── terraform.tfvars      # Prod environment variables
    └── backend.conf          # Prod state backend configuration
```

## Environment Specifications

### Development Environment (dev)

**Infrastructure Characteristics:**
- VPC CIDR: `10.0.0.0/16`
- 2 Availability Zones
- 2 Public Subnets + 2 Private Subnets
- 1 NAT Gateway (single point for cost optimization)
- ECS Services: 1 task per service (minimal cost)
- S3 Bucket Lifecycle: 30-day retention for logs
- Flow Logs Retention: 7 days
- Deletable: All force_destroy flags enabled for easy cleanup
- Auto-scaling: Disabled
- Image Tag Mutability: MUTABLE (for flexibility in dev)
- Container Insights: Enabled

**Cost Profile:** Low - Single instance deployments, short log retention

### Production Environment (prod)

**Infrastructure Characteristics:**
- VPC CIDR: `10.1.0.0/16`
- 3 Availability Zones (High Availability)
- 3 Public Subnets + 3 Private Subnets
- 3 NAT Gateways (one per AZ)
- ECS Services: 
  - API Service: 3 tasks min, 10 max with auto-scaling
  - Notification Service: 2 tasks min, 6 max with auto-scaling
- S3 Bucket Lifecycle: GLACIER (30 days), DEEP_ARCHIVE (90 days)
- Flow Logs Retention: 90 days
- Deletable: All force_destroy flags disabled (safety)
- Auto-scaling: Enabled with CPU/Memory targets
- Image Tag Mutability: IMMUTABLE (safety)
- Repository Policies: Enabled for ECR
- MFA Delete: Disabled (recommend enabling manually)
- Container Insights: Enabled

**Cost Profile:** High - Multi-AZ redundancy, auto-scaling, long log retention

## How to Deploy

### Prerequisites

1. **Install Terraform** (>= 1.0)
   ```bash
   terraform version
   ```

2. **Configure AWS Credentials**
   ```bash
   aws configure
   # or use environment variables:
   export AWS_ACCESS_KEY_ID=...
   export AWS_SECRET_ACCESS_KEY=...
   export AWS_DEFAULT_REGION=us-east-1
   ```

3. **Create S3 Backend Buckets** (one-time setup)
   ```bash
   aws s3api create-bucket --bucket healthcare-terraform-state-dev --region us-east-1
   aws s3api create-bucket --bucket healthcare-terraform-state-prod --region us-east-1
   
   # Enable versioning
   aws s3api put-bucket-versioning --bucket healthcare-terraform-state-dev \
     --versioning-configuration Status=Enabled
   aws s3api put-bucket-versioning --bucket healthcare-terraform-state-prod \
     --versioning-configuration Status=Enabled
   ```

4. **Create DynamoDB Table for Locks** (one-time setup)
   ```bash
   aws dynamodb create-table \
     --table-name terraform-locks \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST
   ```

### Deploy Development Environment

```bash
cd infra

# Initialize with dev backend
terraform init -backend-config=./env/dev/backend.conf

# Plan deployment
terraform plan -var-file=./env/dev/terraform.tfvars

# Apply deployment
terraform apply -var-file=./env/dev/terraform.tfvars
```

### Deploy Production Environment

```bash
cd infra

# Initialize with prod backend
terraform init -backend-config=./env/prod/backend.conf

# Plan deployment
terraform plan -var-file=./env/prod/terraform.tfvars

# Apply deployment (requires explicit approval)
terraform apply -var-file=./env/prod/terraform.tfvars
```

### Switch Between Environments

To switch from dev to prod, re-initialize with the appropriate backend config:

```bash
# Clear local state
rm -rf .terraform/

# Initialize with new backend
terraform init -backend-config=./env/prod/backend.conf

# Use new environment variables
terraform plan -var-file=./env/prod/terraform.tfvars
```

## Environment-Specific Differences

### Networking
| Feature | Dev | Prod |
|---------|-----|------|
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 |
| AZs | 2 | 3 |
| NAT Gateways | 1 | 3 |
| Public IPs | Assigned auto | Not assigned |

### Security
| Feature | Dev | Prod |
|---------|-----|------|
| ECR Image Mutability | MUTABLE | IMMUTABLE |
| ECR Scanning | Enabled | Enabled |
| Force Destroy | Enabled | Disabled |
| VPC Flow Logs | 7 days | 90 days |

### Compute
| Service | Dev | Prod |
|---------|-----|------|
| API Service Tasks | 1 | 3 (auto-scale 3-10) |
| Notification Tasks | 1 | 2 (auto-scale 2-6) |
| Task CPU | 256-512 | 256-512 |
| Task Memory | 512-1024 | 512-1024 |
| Container Insights | Yes | Yes |

### Storage
| Feature | Dev | Prod |
|---------|-----|------|
| S3 Versioning | Enabled | Enabled |
| Log Retention | 30 days | 90 days |
| Lifecycle Policy | Standard | GLACIER/DEEP_ARCHIVE |
| Encryption | AES256 | AES256 |

## Outputs

After deployment, retrieve key infrastructure values:

```bash
# Get all outputs
terraform output

# Get specific output
terraform output -json vpc_id

# Save outputs to file
terraform output -json > infrastructure.json
```

## Important Notes

### Dev Environment
- Perfect for testing and development
- Deletable: Use `terraform destroy` to clean up when done
- Cost-optimized with minimal resources
- Monitor billing to ensure no runaway costs

### Prod Environment
- High availability across 3 AZs
- Auto-scaling enabled for resilience
- Protected against accidental deletion (force_destroy=false)
- Requires explicit approval for Terraform apply
- Consider enabling MFA delete on S3 buckets

## Troubleshooting

### Backend State Lock
If terraform is stuck with a lock:

```bash
# View locks
aws dynamodb scan --table-name terraform-locks

# Manually unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

### S3 State Access Issues
Ensure your AWS credentials have S3 and DynamoDB access:

```bash
aws ec2 describe-vpcs  # Test AWS permissions
```

### Terraform Version Issues
Ensure you're using Terraform 1.0+:

```bash
terraform --version
terraform init -upgrade
```

## Maintenance

### Regular Tasks

1. **Review CloudWatch Logs**
   - Check VPC Flow Logs for network issues
   - Monitor ECS task logs

2. **Update Container Images**
   - Push new tags to ECR
   - Update `container_image` in terraform.tfvars
   - Run `terraform apply`

3. **Monitor Costs**
   - Review AWS billing
   - Adjust resource sizes based on usage

4. **Security Updates**
   - Keep Terraform provider updated
   - Review IAM policies quarterly

## Support

For issues or questions:
1. Check Terraform AWS provider documentation
2. Review AWS CloudWatch logs
3. Check for resource limits in your AWS account
4. Review terraform.tfstate for actual resource configuration

## Cleanup

To destroy an environment:

```bash
cd infra
terraform destroy -var-file=./env/dev/terraform.tfvars  # For dev
# or
terraform destroy -var-file=./env/prod/terraform.tfvars # For prod
```

**WARNING:** Destroying prod environment will delete all infrastructure and data (except S3 with force_destroy=false). Ensure you have backups.
