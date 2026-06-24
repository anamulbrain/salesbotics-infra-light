output "endpoint" {
  description = "RDS hostname"
  value       = aws_db_instance.main.address
}

output "port" {
  value = aws_db_instance.main.port
}

output "db_name" {
  value = aws_db_instance.main.db_name
}

output "db_username" {
  value = aws_db_instance.main.username
}

output "security_group_id" {
  value = aws_security_group.rds.id
}

output "secret_arn" {
  description = "Secrets Manager ARN with DB credentials"
  value       = aws_secretsmanager_secret.db.arn
}

output "db_password" {
  description = "RDS master password"
  value       = random_password.db.result
  sensitive   = true
}

output "database_url" {
  description = "SQLAlchemy-style URL for the SalesBotics API"
  value       = "postgresql+psycopg://${aws_db_instance.main.username}:${random_password.db.result}@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
  sensitive   = true
}

output "auth_jdbc_url" {
  description = "JDBC URL for auth server (auth database must be created once via db-init task)"
  value       = "jdbc:postgresql://${aws_db_instance.main.address}:${aws_db_instance.main.port}/auth"
}
