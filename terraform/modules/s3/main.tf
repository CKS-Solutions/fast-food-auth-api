data "archive_file" "lambda_auth" {
  type = "zip"

  source_dir  = "${path.module}/../../../src/auth"
  output_path = "${path.module}/../../../src/auth.zip"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "fast-food-lambda-bucket"

  tags = var.tags
}

resource "aws_s3_object" "lambda_auth" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "auth.zip"
  source = data.archive_file.lambda_auth.output_path

  etag = filemd5(data.archive_file.lambda_auth.output_path)
}
