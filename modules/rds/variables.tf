variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "db_subnet_ids" {
  description = "Subnets for the DB subnet group (public subnets if publicly_accessible)"
  type        = list(string)
}

variable "publicly_accessible" {
  description = "Assign a public IP to RDS (dev only — requires public subnets)"
  type        = bool
  default     = false
}

variable "admin_cidr_blocks" {
  description = "Optional CIDR blocks for direct psql access (e.g. [\"203.0.113.1/32\"])"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect to PostgreSQL (ECS tasks)"
  type        = list(string)
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "salesbotics"
}

variable "db_username" {
  type    = string
  default = "salesbotics"
}
