output "alb_target_group_arn" {
  value = aws_lb_target_group.target-group.arn
}

output "application_load_balancer_dns_name" {
  value = aws_lb.application_lb.dns_name
}