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

