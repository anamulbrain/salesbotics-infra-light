output "role_arn" {
  description = "IAM role ARN — set as AWS_DEPLOY_ROLE_ARN in the API repo GitHub secrets"
  value       = aws_iam_role.github_deploy.arn
}

output "role_name" {
  value = aws_iam_role.github_deploy.name
}
