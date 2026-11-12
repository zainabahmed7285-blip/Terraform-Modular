# ==============================================================================
# IAM MODULE VARIABLES
# ==============================================================================

variable "environment" {
  description = "Deployment environment name for tagging"
  type        = string
}

variable "project_name" {
  description = "Project name used for naming and tagging resources"
  type        = string
}

