variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "api_image" {
  description = "Full ECR image URI including tag (e.g. 123.dkr.ecr.../salesbotics-dev-api:latest)"
  type        = string
}

variable "tenant_target_group_arn" {
  type = string
}

variable "platform_target_group_arn" {
  type = string
}

variable "storefront_target_group_arn" {
  type = string
}

variable "auth_target_group_arn" {
  type = string
}

variable "database_url" {
  description = "Full DATABASE_URL for API containers"
  type        = string
  sensitive   = true
}

variable "db_host" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "auth_jdbc_url" {
  type = string
}

variable "auth_hostname" {
  type = string
}

variable "tenant_api_hostname" {
  type = string
}

variable "platform_api_hostname" {
  type = string
}

variable "storefront_api_hostname" {
  type = string
}

variable "auth_realm" {
  type    = string
  default = "salesbotics"
}

variable "auth_admin_password" {
  type      = string
  sensitive = true
}

variable "auth_image" {
  description = "Container image for the auth server (Keycloak)"
  type        = string
  default     = "quay.io/keycloak/keycloak:26.0.5"
}

variable "cors_origins" {
  type    = string
  default = "*.salesbotics.io"
}
