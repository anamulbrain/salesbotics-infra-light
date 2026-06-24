module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}

module "alb" {
  source = "../../modules/alb"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.network.vpc_id
  public_subnet_ids       = module.network.public_subnet_ids
  tenant_api_hostname     = var.tenant_api_hostname
  platform_api_hostname   = var.platform_api_hostname
  storefront_api_hostname = var.storefront_api_hostname
  auth_hostname           = var.auth_hostname
  certificate_arn         = var.acm_certificate_arn
}

module "security_groups" {
  source = "../../modules/security-groups"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  alb_security_group_id = module.alb.security_group_id
}

module "rds" {
  source = "../../modules/rds"

  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.network.vpc_id
  private_subnet_ids         = module.network.private_subnet_ids
  allowed_security_group_ids = [module.security_groups.ecs_security_group_id]
}

module "ecs" {
  source = "../../modules/ecs"

  project_name                = var.project_name
  environment                 = var.environment
  aws_region                  = var.aws_region
  vpc_id                      = module.network.vpc_id
  ecs_security_group_id       = module.security_groups.ecs_security_group_id
  public_subnet_ids           = module.network.public_subnet_ids
  alb_security_group_id       = module.alb.security_group_id
  api_image                   = "${module.ecr.repository_url}:${var.api_image_tag}"
  tenant_target_group_arn     = module.alb.tenant_target_group_arn
  platform_target_group_arn   = module.alb.platform_target_group_arn
  storefront_target_group_arn = module.alb.storefront_target_group_arn
  auth_target_group_arn       = module.alb.auth_target_group_arn
  database_url                = module.rds.database_url
  db_host                     = module.rds.endpoint
  db_username                 = module.rds.db_username
  db_password                 = module.rds.db_password
  auth_jdbc_url               = module.rds.auth_jdbc_url
  auth_hostname               = var.auth_hostname
  tenant_api_hostname         = var.tenant_api_hostname
  platform_api_hostname       = var.platform_api_hostname
  storefront_api_hostname     = var.storefront_api_hostname
  auth_admin_password         = local.auth_admin_password
  cors_origins                = var.cors_origins

  depends_on = [module.rds]
}

resource "random_password" "auth_admin" {
  count   = var.auth_admin_password == "" ? 1 : 0
  length  = 24
  special = false
}

locals {
  auth_admin_password = var.auth_admin_password != "" ? var.auth_admin_password : random_password.auth_admin[0].result
}
