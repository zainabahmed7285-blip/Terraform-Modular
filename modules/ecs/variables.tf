# ==============================================================================
# ECS MODULE VARIABLES
# ==============================================================================

variable "vpc_id" {
  description = "The ID of the VPC where the security group and service will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of public subnet IDs where Fargate tasks will be placed"
  type        = list(string)
}

variable "execution_role_arn" {
  description = "ARN of the IAM execution role for ECS tasks"
  type        = string
}

variable "desired_count" {
  description = "Desired number of running ECS task instances"
  type        = number
}

variable "environment" {
  description = "Deployment environment name for tagging"
  type        = string
}

variable "project_name" {
  description = "Project name used for naming and tagging resources"
  type        = string
}

