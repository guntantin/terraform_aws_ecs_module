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
  az_count               = var.az_count
}

# Configure Security Group
module "security_group" {
  source       = "../modules/security-groups"
  vpc_id       = module.network.vpc_id
  my_public_ip = var.my_public_ip
}

# Configure Application Load Balancer
module "alb" {
  source                = "../modules/alb"
  project_name          = module.network.project_name
  alb_security_group_id = module.security_group.alb_security_group_id
  public_subnet_id      = module.network.public_subnet_id
  vpc_id                = module.network.vpc_id
}

module "ecs" {
  source = "../modules/ecs"
  project_name = var.project_name
  app_image = var.app_image
  app_port = var.app_port
  fargate_cpu = var.fargate_cpu
  fargate_memory = var.fargate_memory
  region = var.region
  app_count = var.app_count
  private_subnet_id = module.network.private_subnet_id
  alb_security_group_id = module.security_group.alb_security_group_id
  alb_target_group_arn = module.alb.alb_target_group_arn
}