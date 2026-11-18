# ==============================================================================
# VPC MODULE OUTPUTS
# ==============================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "List of IDs of the 3 public subnets"
  value       = aws_subnet.public[*].id
}

output "app_sg_id" {
  description = "The ID of the security group for the ECS application"
  value       = aws_security_group.app.id
}

