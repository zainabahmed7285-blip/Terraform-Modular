# ==============================================================================
# ECS MODULE VARIABLES
# ==============================================================================

variable "subnet_ids" {
  description = "List of public subnet IDs where Fargate tasks will be placed"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security group ID for the ECS service (created in VPC module)"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the IAM execution role for ECS tasks"
  type        = string
}

variable "desired_count" {
  description = "Desired number of running ECS task instances"
  type        = number
}

variable "container_image" {
  description = "Docker image URI (e.g. from ECR) for the ECS task definition"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 5000
}

variable "db_host" {
  description = "Hostname/address of the RDS database"
  type        = string
}

variable "db_port" {
  description = "Port number of the RDS database"
  type        = any
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret for database credentials"
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
