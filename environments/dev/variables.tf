variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "salesbotics"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs for ap-south-1 (need at least 2 for RDS/ALB later)"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
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
  description = "Optional ACM cert for HTTPS on ALB (leave empty for HTTP-only dev)"
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
  default = "*.salesbotics.io,http://localhost:3000"
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
  description = "Enable RDS public IP for direct psql access (dev only)"
  type        = bool
  default     = true
}

variable "rds_admin_cidr_blocks" {
  description = "Your public IP as CIDR for psql access, e.g. [\"203.0.113.1/32\"]"
  type        = list(string)
  default     = []
}
