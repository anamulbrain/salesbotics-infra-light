output "repository_url" {
  description = "ECR repository URL for docker push"
  value       = aws_ecr_repository.api.repository_url
}

output "repository_arn" {
  value = aws_ecr_repository.api.arn
}

output "repository_name" {
  value = aws_ecr_repository.api.name
}

output "auth_repository_url" {
  description = "ECR repository URL for the Keycloak (auth) image"
  value       = aws_ecr_repository.auth.repository_url
}

output "auth_repository_arn" {
  value = aws_ecr_repository.auth.arn
}
