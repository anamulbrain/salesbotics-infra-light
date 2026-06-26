locals {
  name_prefix   = "${var.project_name}-${var.environment}"
  cluster_name  = "${local.name_prefix}-cluster"
  namespace_dns = "${var.project_name}-${var.environment}.local"
  auth_internal_url = "http://auth.${local.namespace_dns}:8080"
  log_group     = "/ecs/${local.name_prefix}"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = local.log_group
  retention_in_days = 14
}

resource "aws_ecs_cluster" "main" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name = local.namespace_dns
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "auth" {
  name = "auth"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${local.name_prefix}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "${local.name_prefix}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

data "aws_iam_policy_document" "ecs_exec" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_exec" {
  name   = "${local.name_prefix}-ecs-exec"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.ecs_exec.json
}

locals {
  api_common_environment = [
    { name = "DEBUG", value = "false" },
    { name = "DATABASE_URL", value = var.database_url },
    { name = "RUN_PLATFORM_MIGRATIONS", value = "true" },
    { name = "KEYCLOAK_SERVER_URL", value = "https://${var.auth_hostname}" },
    { name = "KEYCLOAK_REALM", value = var.auth_realm },
    { name = "KEYCLOAK_PLATFORM_CLIENT_ID", value = "salesbotics-platform" },
    { name = "KEYCLOAK_TENANT_CLIENT_ID", value = "salesbotics-tenant" },
    { name = "KEYCLOAK_JWKS_URL", value = "${local.auth_internal_url}/realms/${var.auth_realm}/protocol/openid-connect/certs" },
    { name = "KEYCLOAK_ADMIN_URL", value = local.auth_internal_url },
    { name = "KEYCLOAK_ADMIN_USERNAME", value = var.auth_admin_username },
    { name = "KEYCLOAK_ADMIN_PASSWORD", value = var.auth_admin_password },
    { name = "CORS_ORIGINS", value = var.cors_origins },
  ]
}

resource "aws_ecs_task_definition" "tenant_api" {
  family                   = "${local.name_prefix}-tenant-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "tenant-api"
      image     = var.api_image
      essential = true
      command   = ["uvicorn", "app.main_tenant:app", "--host", "0.0.0.0", "--port", "8000"]
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]
      environment = concat(local.api_common_environment, [
        { name = "TENANT_ALLOWED_HOSTS", value = var.tenant_api_hostname },
      ])
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "tenant-api"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "platform_api" {
  family                   = "${local.name_prefix}-platform-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "platform-api"
      image     = var.api_image
      essential = true
      command   = ["uvicorn", "app.main_platform:app", "--host", "0.0.0.0", "--port", "8000"]
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]
      environment = concat(local.api_common_environment, [
        { name = "PLATFORM_ALLOWED_HOSTS", value = var.platform_api_hostname },
      ])
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "platform-api"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "storefront_api" {
  family                   = "${local.name_prefix}-storefront-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "storefront-api"
      image     = var.api_image
      essential = true
      command   = ["uvicorn", "app.main_storefront:app", "--host", "0.0.0.0", "--port", "8000"]
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]
      environment = concat(local.api_common_environment, [
        { name = "STOREFRONT_ALLOWED_HOSTS", value = var.storefront_api_hostname },
      ])
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "storefront-api"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "auth" {
  family                   = "${local.name_prefix}-auth"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "auth"
      image     = var.auth_image
      essential = true
      command   = ["start", "--import-realm"]
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "KC_DB", value = "postgres" },
        { name = "KC_DB_URL", value = var.auth_jdbc_url },
        { name = "KC_DB_USERNAME", value = var.db_username },
        { name = "KC_DB_PASSWORD", value = var.db_password },
        { name = "KC_HOSTNAME", value = "https://${var.auth_hostname}" },
        { name = "KC_HOSTNAME_ADMIN", value = "https://${var.auth_hostname}" },
        { name = "KC_HOSTNAME_STRICT", value = "true" },
        { name = "KC_PROXY_HEADERS", value = "xforwarded" },
        { name = "KC_HTTP_ENABLED", value = "true" },
        { name = "KC_HEALTH_ENABLED", value = "true" },
        { name = "KEYCLOAK_ADMIN", value = var.auth_admin_username },
        { name = "KEYCLOAK_ADMIN_PASSWORD", value = var.auth_admin_password },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "auth"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "db_init" {
  family                   = "${local.name_prefix}-db-init"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "db-init"
      image     = "postgres:16-alpine"
      essential = true
      command = [
        "sh",
        "-c",
        "psql postgresql://${var.db_username}:${var.db_password}@${var.db_host}:5432/postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'auth'\" | grep -q 1 || psql postgresql://${var.db_username}:${var.db_password}@${var.db_host}:5432/postgres -c 'CREATE DATABASE auth;'"
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "db-init"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "migrate_platform" {
  family                   = "${local.name_prefix}-migrate-platform"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "migrate"
      image     = var.api_image
      essential = true
      command   = ["alembic", "upgrade", "head"]
      environment = [
        { name = "DATABASE_URL", value = var.database_url },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "migrate"
        }
      }
    }
  ])
}

locals {
  ecs_service_common = {
    cluster                  = aws_ecs_cluster.main.id
    launch_type              = "FARGATE"
    desired_count            = 1
    subnets                  = var.public_subnet_ids
    security_groups          = [var.ecs_security_group_id]
    assign_public_ip         = true
    enable_execute_command   = true
  }
}

resource "aws_ecs_service" "tenant_api" {
  name                   = "${local.name_prefix}-tenant-api"
  cluster                = local.ecs_service_common.cluster
  task_definition        = aws_ecs_task_definition.tenant_api.arn
  desired_count          = local.ecs_service_common.desired_count
  launch_type            = local.ecs_service_common.launch_type
  enable_execute_command = local.ecs_service_common.enable_execute_command

  network_configuration {
    subnets          = local.ecs_service_common.subnets
    security_groups  = local.ecs_service_common.security_groups
    assign_public_ip = local.ecs_service_common.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.tenant_target_group_arn
    container_name   = "tenant-api"
    container_port   = 8000
  }

  depends_on = [aws_ecs_service.auth]
}

resource "aws_ecs_service" "platform_api" {
  name                   = "${local.name_prefix}-platform-api"
  cluster                = local.ecs_service_common.cluster
  task_definition        = aws_ecs_task_definition.platform_api.arn
  desired_count          = local.ecs_service_common.desired_count
  launch_type            = local.ecs_service_common.launch_type
  enable_execute_command = local.ecs_service_common.enable_execute_command

  network_configuration {
    subnets          = local.ecs_service_common.subnets
    security_groups  = local.ecs_service_common.security_groups
    assign_public_ip = local.ecs_service_common.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.platform_target_group_arn
    container_name   = "platform-api"
    container_port   = 8000
  }

  depends_on = [aws_ecs_service.auth]
}

resource "aws_ecs_service" "storefront_api" {
  name                   = "${local.name_prefix}-storefront-api"
  cluster                = local.ecs_service_common.cluster
  task_definition        = aws_ecs_task_definition.storefront_api.arn
  desired_count          = local.ecs_service_common.desired_count
  launch_type            = local.ecs_service_common.launch_type
  enable_execute_command = local.ecs_service_common.enable_execute_command

  network_configuration {
    subnets          = local.ecs_service_common.subnets
    security_groups  = local.ecs_service_common.security_groups
    assign_public_ip = local.ecs_service_common.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.storefront_target_group_arn
    container_name   = "storefront-api"
    container_port   = 8000
  }

  depends_on = [aws_ecs_service.auth]
}

resource "aws_ecs_service" "auth" {
  name                   = "${local.name_prefix}-auth"
  cluster                = local.ecs_service_common.cluster
  task_definition        = aws_ecs_task_definition.auth.arn
  desired_count          = local.ecs_service_common.desired_count
  launch_type            = local.ecs_service_common.launch_type
  enable_execute_command = local.ecs_service_common.enable_execute_command

  network_configuration {
    subnets          = local.ecs_service_common.subnets
    security_groups  = local.ecs_service_common.security_groups
    assign_public_ip = local.ecs_service_common.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.auth_target_group_arn
    container_name   = "auth"
    container_port   = 8080
  }

  service_registries {
    registry_arn = aws_service_discovery_service.auth.arn
  }
}
