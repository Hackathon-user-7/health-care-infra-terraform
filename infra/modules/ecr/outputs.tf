output "repository_arn" {
  description = "The ARN of the ECR repository"
  value       = aws_ecr_repository.main.arn
}

output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.main.name
}

output "registry_id" {
  description = "The AWS account ID where the repository is located"
  value       = aws_ecr_repository.main.registry_id
}

output "repository_uri" {
  description = "The full URI of the ECR repository"
  value       = "${aws_ecr_repository.main.registry_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${aws_ecr_repository.main.repository_url}"
}
