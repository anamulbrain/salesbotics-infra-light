output "auth_internal_url" {
  value = local.auth_internal_url
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "execution_role_arn" {
  value = aws_iam_role.execution.arn
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}

output "db_init_task_definition" {
  value = aws_ecs_task_definition.db_init.family
}

output "migrate_task_definition" {
  value = aws_ecs_task_definition.migrate_platform.family
}

output "service_names" {
  value = {
    tenant_api     = aws_ecs_service.tenant_api.name
    platform_api   = aws_ecs_service.platform_api.name
    storefront_api = aws_ecs_service.storefront_api.name
    auth           = aws_ecs_service.auth.name
  }
}
