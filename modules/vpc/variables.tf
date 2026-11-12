# ==============================================================================
# VPC MODULE VARIABLES
# ==============================================================================

variable "vpc_cidr" {
  description = "The primary CIDR block for the VPC"
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

