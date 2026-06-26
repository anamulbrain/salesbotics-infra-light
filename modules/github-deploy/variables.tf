variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "github_org" {
  description = "GitHub organization or user that owns the API repository"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name for the API (CI/CD deploys from main)"
  type        = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_execution_role_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "ecr_api_repository_arn" {
  type = string
}

variable "ecr_auth_repository_arn" {
  type = string
}

variable "github_oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN; leave empty to create one in this account"
  type        = string
  default     = ""
}
