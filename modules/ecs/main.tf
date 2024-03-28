resource "aws_ecs_cluster" "web-cluster" {
  name = "myapp-cluster"
}

data "template_file" "webapp" {
  template = file("../modules/templates/image/image.json")

  vars = {
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.region
  }
}

resource "aws_ecs_task_definition" "web-def" {
  family                   = "webapp-task"
  execution_role_arn       = var.ecs_task_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.webapp.rendered
}

resource "aws_ecs_service" "web-service" {
  name            = "webapp-service"
  cluster         = aws_ecs_cluster.web-cluster.id
  task_definition = aws_ecs_task_definition.web-def.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.alb_security_group_id]
    subnets          = [
      var.private_subnet_az1_id,
      var.private_subnet_az2_id
    ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "webapp"
    container_port   = var.app_port
  }

  #depends_on = [var.aws_lb_listener.lb_http, var.aws_iam_role_policy_attachment.ecs_task_execution_role]
}
