resource "aws_ecr_repository" "myreg" {
  name                 = "nginx"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

output "arn" {
  value       = aws_ecr_repository.myreg.arn
  description = "Full ARN of the repository"
}

output "name" {
  value       = aws_ecr_repository.myreg.name
  description = "Name of the repository"
}

output "repository_url" {
  value       = aws_ecr_repository.myreg.repository_url
  description = "URL of the repository"
}

output "registry_id" {
  value       = aws_ecr_repository.myreg.registry_id
  description = "Registry ID where the repository was created"
}
