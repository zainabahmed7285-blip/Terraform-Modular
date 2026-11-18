# ==============================================================================
# ROOT MODULE - MAIN CONFIGURATION
# ==============================================================================
# This root configuration coordinates child modules to deploy a complete,
# modular infrastructure on AWS consisting of:
# - VPC with 3 public subnets and ECS application security group
# - S3 private bucket with unique name
# - RDS PostgreSQL database with Secrets Manager password management
# - IAM execution role for ECS tasks with Secrets Manager access
# - ECS cluster and Fargate service running containerized application
# ==============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# AWS Provider configuration
provider "aws" {
  region = var.aws_region
}

# 1. VPC Child Module: Creates network foundation & ECS app security group
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr       = var.vpc_cidr
  container_port = var.container_port
  environment    = var.environment
  project_name   = var.project_name
}

# 2. S3 Child Module: Creates a private S3 bucket with a unique random suffix
module "s3" {
  source = "./modules/s3"

  bucket_prefix = var.bucket_prefix
  environment   = var.environment
  project_name  = var.project_name
}

# 3. RDS Child Module: Creates the PostgreSQL database with AWS Secrets Manager
module "rds" {
  source = "./modules/rds"

  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.subnet_ids
  app_sg_id    = module.vpc.app_sg_id
  environment  = var.environment
  project_name = var.project_name
}

# 4. IAM Child Module: Creates ECS task execution IAM role & policies
module "iam" {
  source = "./modules/iam"

  secret_arn   = module.rds.secret_arn
  environment  = var.environment
  project_name = var.project_name
}

# 5. ECS Child Module: Creates cluster, log group, task definition, and service
module "ecs" {
  source = "./modules/ecs"

  subnet_ids         = module.vpc.subnet_ids
  app_sg_id          = module.vpc.app_sg_id
  execution_role_arn = module.iam.execution_role_arn
  desired_count      = var.ecs_desired_count
  container_image    = var.container_image
  container_port     = var.container_port
  db_host            = module.rds.db_address
  db_port            = module.rds.db_port
  db_name            = module.rds.db_name
  db_secret_arn      = module.rds.secret_arn
  environment        = var.environment
  project_name       = var.project_name
}
