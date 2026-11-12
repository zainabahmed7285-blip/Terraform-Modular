# ==============================================================================
# S3 MODULE VARIABLES
# ==============================================================================

variable "bucket_prefix" {
  description = "Prefix for naming the S3 bucket"
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

