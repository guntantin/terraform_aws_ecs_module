# Configure aws provider
provider "aws" {
  region = var.region
}

# Configure network
module "network" {
  source                 = "../modules/network"
  region                 = var.region
  project_name           = var.project_name
  vpc_cidr               = var.vpc_cidr
  public_subnet_az1_cidr = var.public_subnet_az1_cidr
  public_subnet_az2_cidr = var.public_subnet_az2_cidr
  private_subnet_az1_cidr = var.private_subnet_az1_cidr
  private_subnet_az2_cidr = var.private_subnet_az2_cidr

}

# Configure Security Group
module "security_group" {
  source       = "../modules/security-groups"
  vpc_id       = module.network.vpc_id
  my_public_ip = var.my_public_ip
}

# 
module "ecs_tasks_execution_role" {
  source       = "../modules/iam_role"
  project_name = var.project_name
}

# Configure Application Load Balancer
module "alb" {
  source                = "../modules/alb"
  project_name          = module.network.project_name
  alb_security_group_id = module.security_group.alb_security_group_id
  public_subnet_az1_id  = module.network.public_subnet_az1_id
  public_subnet_az2_id  = module.network.public_subnet_az2_id
  vpc_id                = module.network.vpc_id
}

# Configure Auto Scaling groups
module "asg" {
  source                     = "../modules/asg"
  aws_ecs_cluster_web-cluster_name = module.ecs.aws_ecs_cluster_web-cluster_name
  aws_ecs_service_web-service_name = module.ecs.aws_ecs_service_web-service_name
}

module "ecs" {
  source = "../modules/ecs"
  app_image = var.app_image
  app_port = var.app_port
  fargate_cpu = var.fargate_cpu
  fargate_memory = var.fargate_memory
  region = var.region
  app_count = var.app_count
  private_subnet_az1_id = module.network.private_subnet_az1_id
  private_subnet_az2_id = module.network.private_subnet_az2_id
  alb_security_group_id = module.security_group.alb_security_group_id
  ecs_task_execution_role_arn = module.ecs_tasks_execution_role.ecs_task_execution_role_arn
  alb_target_group_arn = module.alb.alb_target_group_arn
}