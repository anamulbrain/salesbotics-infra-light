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
