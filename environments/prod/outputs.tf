output "aws_account_id" {
  description = "Production AWS account where resources were created"
  value       = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  description = "Production VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Production public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Production private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "vpc_cidr" {
  description = "Production VPC CIDR"
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

output "ecr_auth_repository_url" {
  description = "Docker push target for the Keycloak (auth) image"
  value       = module.ecr.auth_repository_url
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

output "github_deploy_role_arn" {
  description = "Add as AWS_DEPLOY_ROLE_ARN secret in the prod GitHub Environment"
  value       = module.github_deploy.role_arn
}

output "deploy_steps" {
  description = "Run these after terraform apply"
  value       = <<-EOT
    GitHub Actions (API repo):
      1. terraform apply here once, then set GitHub Environment "prod" secret AWS_DEPLOY_ROLE_ARN = github_deploy_role_arn output
      2. Create GitHub Environment "prod" on the API repo (Settings → Environments) with required reviewers if desired
      3. Use deploy-prod workflow (or comment on a prod deploy issue) to build images and update ECS

    Manual fallback:
      1. aws sso login (management account) && export AWS_PROFILE=...
      2. Push API image: docker build -t <ecr_repository_url>:latest . && docker push ...
      3. Push auth image: docker build -t <ecr_auth_repository_url>:latest keycloak && docker push ...
      4. Run db-init task once to create auth database (first deploy only).
      5. Run scripts/ecs-deploy.sh with ECS_CLUSTER=salesbotics-prod-cluster NAME_PREFIX=salesbotics-prod
      6. Point Cloudflare DNS CNAMEs to alb_dns_name for all 4 hostnames.
  EOT
}
