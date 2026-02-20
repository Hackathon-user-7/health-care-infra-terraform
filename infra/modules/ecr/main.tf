resource "aws_ecr_repository" "main" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key
  }

  tags = merge(
    var.tags,
    {
      Name = var.repository_name
    }
  )
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = var.lifecycle_policy
}

resource "aws_ecr_repository_policy" "main" {
  count      = var.create_repository_policy ? 1 : 0
  repository = aws_ecr_repository.main.name
  policy     = var.repository_policy
}
