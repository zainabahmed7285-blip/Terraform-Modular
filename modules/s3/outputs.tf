# ==============================================================================
# S3 MODULE OUTPUTS
# ==============================================================================

output "bucket_name" {
  description = "The globally unique name of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "The Amazon Resource Name (ARN) of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

