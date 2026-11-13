# ==============================================================================
# ROOT MODULE - MAIN CONFIGURATION
# ==============================================================================
# This root configuration coordinates child modules to deploy a complete,
# modular infrastructure on AWS consisting of:
# - VPC with 3 public subnets across 3 Availability Zones
# - S3 private bucket with unique name
# - IAM execution role for ECS tasks
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

# 1. VPC Child Module: Creates the network foundation
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr     = var.vpc_cidr
  environment  = var.environment
  project_name = var.project_name
}

# 2. S3 Child Module: Creates a private S3 bucket with a unique random suffix
module "s3" {
  source = "./modules/s3"

  bucket_prefix = var.bucket_prefix
  environment   = var.environment
  project_name  = var.project_name
}

# 3. IAM Child Module: Creates the ECS task execution IAM role & policy attachment
module "iam" {
  source = "./modules/iam"

  environment  = var.environment
  project_name = var.project_name
}

# 4. ECS Child Module: Creates the cluster, log group, security group, task definition, and service
module "ecs" {
  source = "./modules/ecs"

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.subnet_ids
  execution_role_arn = module.iam.execution_role_arn
  desired_count      = var.ecs_desired_count
  container_image    = var.container_image
  container_port     = var.container_port
  environment        = var.environment
  project_name       = var.project_name
}

