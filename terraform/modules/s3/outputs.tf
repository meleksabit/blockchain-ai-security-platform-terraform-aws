output "ai_model_storage_bucket" {
  value = aws_s3_bucket.ai_model_storage.bucket
}

output "logs_exports_bucket" {
  value = aws_s3_bucket.logs_exports.bucket
}
