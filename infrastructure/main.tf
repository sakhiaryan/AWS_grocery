# ============================================================
# GroceryMate - Root Terraform configuration
# Wires all modules together.
# ============================================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws     = { source = "hashicorp/aws",     version = "~> 5.0" }
    archive = { source = "hashicorp/archive", version = "~> 2.0" }
    random  = { source = "hashicorp/random",  version = "~> 3.0" }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "sakhiaryan"
  }
  bucket_name = coalesce(var.s3_bucket_name, "${var.project_name}-assets-${random_id.suffix.hex}")
}

resource "random_id" "suffix" {
  byte_length = 3
}

# 1) Network
module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  tags         = local.common_tags
}

# 2) Security Groups
module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  app_port     = var.app_port
  ssh_cidr     = var.allowed_ssh_cidr
  tags         = local.common_tags
}

# 3) S3 first (IAM needs bucket ARN)
module "s3" {
  source      = "./modules/s3"
  bucket_name = local.bucket_name
  tags        = local.common_tags
}

# 4) IAM (after S3, before compute/lambda)
module "iam" {
  source        = "./modules/iam"
  project_name  = var.project_name
  s3_bucket_arn = module.s3.bucket_arn
  tags          = local.common_tags
}

# 5) Compute = ALB + ASG + Launch Template
module "compute" {
  source                = "./modules/compute"
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_sg_id             = module.security.alb_sg_id
  ec2_sg_id             = module.security.ec2_sg_id
  instance_profile_name = module.iam.ec2_instance_profile_name
  instance_type         = var.ec2_instance_type
  key_name              = var.ec2_key_name
  app_port              = var.app_port
  asg_min               = var.asg_min
  asg_max               = var.asg_max
  asg_desired           = var.asg_desired
  tags                  = local.common_tags
}

# 6) RDS
module "rds" {
  source             = "./modules/rds"
  project_name       = var.project_name
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.security.rds_sg_id
  instance_class     = var.db_instance_class
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  tags               = local.common_tags
}

# 7) Lambda + EventBridge
module "lambda" {
  source           = "./modules/lambda"
  project_name     = var.project_name
  role_arn         = module.iam.lambda_role_arn
  target_group_arn = module.compute.target_group_arn
  tags             = local.common_tags
}
