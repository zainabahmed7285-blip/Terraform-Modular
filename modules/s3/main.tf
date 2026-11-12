# ==============================================================================
# S3 MODULE - MAIN CONFIGURATION
# ==============================================================================
# This module creates:
# 1. A random lowercase alphanumeric string for a globally unique bucket name
# 2. An Amazon S3 bucket with tags
# 3. An S3 bucket public access block to ensure the bucket is private
# ==============================================================================

# 1. Generate a random suffix to ensure the S3 bucket name is globally unique
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# 2. Amazon S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = "${var.bucket_prefix}-${random_string.suffix.result}"

  tags = {
    Name        = "${var.bucket_prefix}-${random_string.suffix.result}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 3. Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

