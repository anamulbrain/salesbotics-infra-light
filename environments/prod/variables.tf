variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "aws_assume_role_arn" {
  description = "Role in the production account (440977419872). Run Terraform from the management account and assume this role."
  type        = string
  default     = "arn:aws:iam::440977419872:role/OrganizationAccountAccessRole"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "salesbotics"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR block (must not overlap dev 10.0.0.0/16)"
  type        = string
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "AZs for ap-south-1 (need at least 2 for RDS/ALB)"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["10.1.11.0/24", "10.1.12.0/24"]
}

# --- API hostnames (must match Cloudflare DNS + ALB rules) ---

variable "tenant_api_hostname" {
  type    = string
  default = "api.salesbotics.io"
}

variable "platform_api_hostname" {
  type    = string
  default = "staffapi.salesbotics.io"
}

variable "storefront_api_hostname" {
  type    = string
  default = "shopapi.salesbotics.io"
}

variable "auth_hostname" {
  type    = string
  default = "auth.salesbotics.io"
}

variable "acm_certificate_arn" {
  description = "ACM cert for HTTPS on ALB in ap-south-1 (production account)"
  type        = string
  default     = ""
}

variable "api_image_tag" {
  description = "Docker tag pushed to ECR (use after first docker push)"
  type        = string
  default     = "latest"
}

variable "cors_origins" {
  type    = string
  default = "https://salesbotics.io,https://*.salesbotics.io"
}

variable "auth_admin_username" {
  description = "Keycloak master-realm admin username"
  type        = string
  default     = "admin"
}

variable "auth_admin_password" {
  description = "Auth server admin password (leave empty to auto-generate)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "rds_publicly_accessible" {
  description = "Keep false in production — RDS stays in private subnets"
  type        = bool
  default     = false
}

variable "rds_admin_cidr_blocks" {
  description = "Optional CIDRs for direct psql access if rds_publicly_accessible is true"
  type        = list(string)
  default     = []
}

variable "github_org" {
  description = "GitHub org/user that owns the API repository (for Actions OIDC)"
  type        = string
  default     = "salesbotics"
}

variable "github_api_repo" {
  description = "API repository name deployed by GitHub Actions"
  type        = string
  default     = "salesbotics-api-light"
}

variable "github_oidc_provider_arn" {
  description = "Set if this AWS account already has a GitHub OIDC provider"
  type        = string
  default     = ""
}
