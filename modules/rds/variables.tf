# ==============================================================================
# RDS MODULE VARIABLES
# ==============================================================================

variable "vpc_id" {
  description = "The ID of the VPC where RDS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS DB subnet group"
  type        = list(string)
}

variable "app_sg_id" {
  description = "ID of the ECS application security group allowed to connect to PostgreSQL"
  type        = string
}

variable "environment" {
  description = "Deployment environment name for tagging"
  type        = string
}

variable "project_name" {
  description = "Project name used for naming and tagging resources"
  type        = string
}
