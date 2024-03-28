variable "project_name" {
  description = "Project name"
  type        = string
  default     = "webapp"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = map(string)
  default = {
    "dev"   = "10.0.0.0/16",
    "stage" = "11.0.0.0/16",
    "prod"  = "12.0.0.0/16"
  }
}

variable "public_subnet_az1_cidr" {
  description = "Subnet in AZ a"
  type        = map(string)
  default = {
    "dev"   = "10.0.10.0/24",
    "stage" = "11.0.10.0/24",
    "prod"  = "12.0.10.0/24"
  }
}

variable "public_subnet_az2_cidr" {
  description = "Subnet in AZ b"
  type        = map(string)
  default = {
    "dev"   = "10.0.11.0/24",
    "stage" = "11.0.11.0/24",
    "prod"  = "12.0.11.0/24"
  }
}

variable "private_subnet_az1_cidr" {
  description = "Subnet in AZ a"
  type        = map(string)
  default = {
    "dev"   = "10.0.12.0/24",
    "stage" = "11.0.12.0/24",
    "prod"  = "12.0.12.0/24"
  }
}

variable "private_subnet_az2_cidr" {
  description = "Subnet in AZ b"
  type        = map(string)
  default = {
    "dev"   = "10.0.13.0/24",
    "stage" = "11.0.13.0/24",
    "prod"  = "12.0.13.0/24"
  }
}

variable "my_public_ip" {
  type        = string
  description = "My public IP address"
  default     = "0.0.0.0/0"
}

# variable "avalablility_zones" {
#   description = "Avalablility zones in the Region"
#   type        = list(string)
#   default = [
#     "eu-central-1a",
#     "eu-central-1b",
#     "eu-central-1c",
#   ]
# }

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-central-1"
}

variable "amis" {
  type = map(string)
  default = {
    "eu-central-1" = "ami-04e601abe3e1a910f"
  }
}

variable "ingress_ports" {
  description = "List of Ingress Ports"
  type        = list(number)
  default     = [80, 3000]
}

variable "asg_max_size" {
  description = "For max size use 2 instance"
  type        = string
  default     = 4
}

variable "asg_min_size" {
  description = "For max size use 2 instance"
  type        = string
  default     = 2
}

variable "asg_desired_capacity" {
  description = "For max size use 2 instance"
  type        = string
  default     = 2
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Free Tier"
  type        = string
}

variable "app_image" {
  default = "nginx:latest"
}

variable "app_port" {
  default = "80"
} 


variable "fargate_cpu" {
  default     = "1024"
  description = "fargate instacne CPU units to provision,my requirent 1 vcpu so gave 1024"
}

variable "fargate_memory" {
  default     = "2048"
  description = "Fargate instance memory to provision (in MiB) not MB"
}

variable "app_count" {
  default     = "2" # choose 2 bcz i have choosen 2 AZ
  description = "numer of docker containers to run"
}

variable "ecs_task_execution_role" {
  default     = "myECcsTaskExecutionRole"
  description = "ECS task execution role name"
}