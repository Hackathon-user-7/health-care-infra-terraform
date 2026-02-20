#!/bin/bash
# Healthcare Microservice - Terraform Backend Setup with Native State Locking
# This script sets up S3 backend with DynamoDB state locking

set -e

ENVIRONMENT=${1:-dev}
AWS_REGION=${2:-us-east-1}

if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
    echo "Usage: $0 [dev|prod] [aws-region]"
    echo "Example: $0 dev us-east-1"
    exit 1
fi

echo "Setting up Terraform backend with native locking for $ENVIRONMENT environment..."
echo "AWS Region: $AWS_REGION"

STATE_BUCKET="healthcare-terraform-state-${ENVIRONMENT}"
LOCK_TABLE="terraform-locks"

# Create S3 bucket for state
echo ""
echo "Step 1: Creating S3 bucket for state ($STATE_BUCKET)..."
if aws s3api head-bucket --bucket "$STATE_BUCKET" --region "$AWS_REGION" 2>/dev/null; then
    echo "  ✓ S3 bucket already exists"
else
    if [ "$AWS_REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket "$STATE_BUCKET" \
            --region "$AWS_REGION"
    else
        aws s3api create-bucket \
            --bucket "$STATE_BUCKET" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"
    fi
    echo "  ✓ S3 bucket created"
fi

# Enable versioning
echo ""
echo "Step 2: Enabling S3 versioning for state protection..."
aws s3api put-bucket-versioning \
    --bucket "$STATE_BUCKET" \
    --versioning-configuration Status=Enabled
echo "  ✓ Versioning enabled"

# Enable encryption
echo ""
echo "Step 3: Enabling S3 encryption..."
aws s3api put-bucket-encryption \
    --bucket "$STATE_BUCKET" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'
echo "  ✓ Encryption enabled"

# Block public access
echo ""
echo "Step 4: Blocking public access to S3 bucket..."
aws s3api put-public-access-block \
    --bucket "$STATE_BUCKET" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo "  ✓ Public access blocked"

# Create DynamoDB table for state locking
echo ""
echo "Step 5: Creating DynamoDB table for state locking ($LOCK_TABLE)..."
if aws dynamodb describe-table --table-name "$LOCK_TABLE" --region "$AWS_REGION" 2>/dev/null; then
    echo "  ✓ DynamoDB table already exists"
else
    aws dynamodb create-table \
        --table-name "$LOCK_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$AWS_REGION"
    
    # Wait for table to be active
    echo "  Waiting for DynamoDB table to be active..."
    aws dynamodb wait table-exists \
        --table-name "$LOCK_TABLE" \
        --region "$AWS_REGION"
    echo "  ✓ DynamoDB table created and active"
fi

# Initialize Terraform
echo ""
echo "Step 6: Initializing Terraform with backend configuration..."
cd "$(dirname "$0")/.."

terraform init \
    -backend-config=./env/"$ENVIRONMENT"/backend.conf \
    -upgrade

echo ""
echo "✓ Backend setup complete!"
echo ""
echo "Backend Configuration Summary:"
echo "  S3 Bucket: $STATE_BUCKET"
echo "  DynamoDB Lock Table: $LOCK_TABLE"
echo "  Environment: $ENVIRONMENT"
echo "  Region: $AWS_REGION"
echo ""
echo "Native State Locking Features Enabled:"
echo "  • S3 versioning: Protects against accidental overwrites"
echo "  • S3 encryption: Encrypts state data at rest"
echo "  • S3 public access block: Prevents unauthorized access"
echo "  • DynamoDB locking: Prevents concurrent modifications"
echo ""
echo "Next steps:"
echo "  1. Run: terraform plan -var-file=./env/$ENVIRONMENT/terraform.tfvars"
echo "  2. Review the planned changes"
echo "  3. Run: terraform apply -var-file=./env/$ENVIRONMENT/terraform.tfvars"
