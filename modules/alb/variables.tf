variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
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

variable "auth_hostname" {
  type = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (optional for dev)"
  type        = string
  default     = ""
}
