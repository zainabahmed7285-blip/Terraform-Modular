# ==============================================================================
# IAM MODULE VARIABLES
# ==============================================================================

variable "environment" {
  description = "Deployment environment name for tagging"
  type        = string
}

variable "secret_arn" {
  description = "ARN of the Secrets Manager secret for RDS credentials"
  type        = string
}

variable "project_name" {
  description = "Project name used for naming and tagging resources"
  type        = string
}

