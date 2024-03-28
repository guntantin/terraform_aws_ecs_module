output "alb_security_group_id" {
    value = aws_security_group.alb_security_group.id
}

output "inctance_security_group_id" {
    value = aws_security_group.inctance_security_group.id
}