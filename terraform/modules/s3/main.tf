# -------------------------------------------------------
# Create S3 buckets for AI model storage and logs storage
# -------------------------------------------------------

# S3 Bucket for AI Model Storage
resource "aws_s3_bucket" "ai_model_storage" {
  bucket = "blockchain-ai-models-${var.project_suffix}"

  tags = {
    Name        = "Blockchain AI Model Storage"
    Environment = var.environment
  }
}

# S3 Bucket for Logs Storage
resource "aws_s3_bucket" "logs_exports" {
  bucket = "blockchain-logs-${var.project_suffix}"

  tags = {
    Name        = "Blockchain Logs Storage"
    Environment = var.environment
  }
}

# Block Public Access (Recommended)
resource "aws_s3_bucket_public_access_block" "ai_model_storage_block" {
  bucket                  = aws_s3_bucket.ai_model_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "logs_exports_block" {
  bucket                  = aws_s3_bucket.logs_exports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket Policy for IAM Role Access
resource "aws_s3_bucket_policy" "ai_model_storage_policy" {
  bucket = aws_s3_bucket.ai_model_storage.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = var.s3_role_arn }
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.ai_model_storage.arn,
        "${aws_s3_bucket.ai_model_storage.arn}/*"
      ]
    }]
  })
}

# Bucket Policy for Logs Exports
resource "aws_s3_bucket_policy" "logs_exports_policy" {
  bucket = aws_s3_bucket.logs_exports.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = var.s3_role_arn }
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.logs_exports.arn,
        "${aws_s3_bucket.logs_exports.arn}/*"
      ]
    }]
  })
}

# Lifecycle Configuration for AI Model Storage
resource "aws_s3_bucket_lifecycle_configuration" "ai_model_storage_lifecycle" {
  bucket = aws_s3_bucket.ai_model_storage.id

  rule {
    id     = "delete-old-models"
    status = "Enabled"

    expiration {
      days = 180 # Delete objects after 6 months
    }
  }
}

# Lifecycle Configuration for Logs Exports
resource "aws_s3_bucket_lifecycle_configuration" "logs_exports_lifecycle" {
  bucket = aws_s3_bucket.logs_exports.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    expiration {
      days = 90 # Delete logs after 3 months
    }
  }
}
