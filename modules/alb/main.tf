# Create Application Load Balancer
resource "aws_lb" "application_lb" {
  name               = "${terraform.workspace}-${var.project_name}-alb"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = [var.public_subnet_az1_id, var.public_subnet_az2_id]

  tags = {
    Name = "${terraform.workspace}-${var.project_name}-alb"
  }
}

# Create alb target group
resource "aws_lb_target_group" "target-group" {
  name        = "${terraform.workspace}-${var.project_name}-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

# redirecting all incomming traffic from ALB to the target group
resource "aws_lb_listener" "lb_http" {
  load_balancer_arn = aws_lb.application_lb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target-group.arn
    type             = "forward"
  }

}