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
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn
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

  depends_on = [aws_iam_role_policy_attachment.ecs_tasks_execution_role]
}

# generate an iam policy document in json format for the ecs task execution
data "aws_iam_policy_document" "ecs_tasks_execution_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# create an iam role
resource "aws_iam_role" "ecs_tasks_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role_policy.json
}

# attach ecs taks execution policy to the iam role
resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# logs.tf
# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "webapp_log_group" {
  name              = "/ecs/webapp"
  retention_in_days = 30

  tags = {
    Name = "cw-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "myapp_log_stream" {
  name           = "log-stream"
  log_group_name = aws_cloudwatch_log_group.webapp_log_group.name
}
