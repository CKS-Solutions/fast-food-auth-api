output "lambda_bucket_id" {
  description = "ID of the Lambda bucket"
  value       = aws_s3_bucket.lambda_bucket.id
}

output "lambda_auth_key" {
  description = "Key of the Lambda auth object"
  value       = aws_s3_object.lambda_auth.key
}

output "lambda_auth_base64sha256" {
  description = "Base64sha256 of the Lambda auth object"
  value       = data.archive_file.lambda_auth.output_base64sha256
}
