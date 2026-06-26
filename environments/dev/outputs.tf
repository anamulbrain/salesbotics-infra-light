output "vpc_id" {
  description = "Dev VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Dev public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Dev private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "vpc_cidr" {
  description = "Dev VPC CIDR"
  value       = module.network.vpc_cidr
}

output "alb_dns_name" {
  description = "Create Cloudflare CNAME records pointing here"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "Docker push target for the API image"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "database_url" {
  description = "SQLAlchemy DATABASE_URL (sensitive)"
  value       = module.rds.database_url
  sensitive   = true
}

output "auth_admin_password" {
  description = "Auth server admin console password (see auth_admin_username in tfvars)"
  value       = local.auth_admin_password
  sensitive   = true
}

output "api_hostnames" {
  value = {
    tenant     = var.tenant_api_hostname
    platform   = var.platform_api_hostname
    storefront = var.storefront_api_hostname
    auth       = var.auth_hostname
  }
}

output "deploy_steps" {
  description = "Run these after terraform apply"
  value       = <<-EOT
    1. Push API image to ECR (see ecr_repository_url).
    2. Run db-init task once to create auth database (first deploy only).
    3. Platform migrations run automatically on API container startup.
    4. Point Cloudflare DNS CNAMEs to alb_dns_name for all 4 hostnames.
    5. Force new ECS deployment if tasks were unhealthy before image push.
  EOT
}
