# ==============================================================================
# ROOT MODULE VARIABLES
# ==============================================================================
# These variables configure your overall infrastructure deployment.
# You can set custom values for these variables in a terraform.tfvars file.
# ==============================================================================

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "The name of the project used to prefix and tag resources"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC (e.g., 10.0.0.0/16)"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name (will be combined with a random suffix)"
  type        = string
}

variable "ecs_desired_count" {
  description = "The desired number of running tasks for the ECS service"
  type        = number
  default     = 2
}

