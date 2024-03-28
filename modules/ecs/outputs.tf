output "aws_ecs_cluster_web-cluster_name" {
  value = aws_ecs_cluster.web-cluster.name
}

output "aws_ecs_service_web-service_name" {
  value = aws_ecs_service.web-service.name
}