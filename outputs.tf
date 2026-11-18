# ==============================================================================
# ROOT MODULE OUTPUTS
# ==============================================================================
# These outputs expose values from child modules after Terraform applies changes.
# ==============================================================================

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "The IDs of the 3 public subnets in different availability zones"
  value       = module.vpc.subnet_ids
}

output "bucket_name" {
  description = "The name of the created private S3 bucket"
  value       = module.s3.bucket_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "The name of the ECS Fargate service"
  value       = module.ecs.service_name
}

output "db_endpoint" {
  description = "The connection endpoint address of the RDS PostgreSQL database"
  value       = module.rds.db_address
}

output "db_name" {
  description = "The RDS database name"
  value       = module.rds.db_name
}
