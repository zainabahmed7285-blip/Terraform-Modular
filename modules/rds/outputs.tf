# ==============================================================================
# RDS MODULE OUTPUTS
# ==============================================================================

output "db_address" {
  description = "The connection endpoint address of the RDS database"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "The port on which the RDS database accepts connections"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.main.db_name
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret storing the master user password"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}
