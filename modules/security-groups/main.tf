# Creata Securety Group for the application load balancer
resource "aws_security_group" "alb_security_group" {
  name = "alb security group"
  description = "enable http and web-app access on port 80/3000"
  vpc_id = var.vpc_id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${terraform.workspace}-alb_security_group"
  }
}

# Create security group for the containers
resource "aws_security_group" "inctance_security_group" {
  name = "inctance security group"
  description = "enable ssh access on port 22 and specific port"
  vpc_id = var.vpc_id

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip]
  }

  ingress {
    description = "web-app access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${terraform.workspace}-inctance_security_group"
  }
}