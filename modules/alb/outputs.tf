output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "Point Cloudflare CNAME records here"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  value = aws_lb.main.zone_id
}

output "security_group_id" {
  value = aws_security_group.alb.id
}

output "tenant_target_group_arn" {
  value = aws_lb_target_group.tenant_api.arn
}

output "platform_target_group_arn" {
  value = aws_lb_target_group.platform_api.arn
}

output "storefront_target_group_arn" {
  value = aws_lb_target_group.storefront_api.arn
}

output "auth_target_group_arn" {
  value = aws_lb_target_group.auth.arn
}
