# Lambda function
resource "aws_lambda_function" "api_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.function_name
  role             = var.lambda_role_arn
  handler          = "auth.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size

  environment {
    variables = var.environment_variables
  }

  tags = var.tags
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../src/auth.js"
  output_path = "/tmp/lambda_function.zip"
}
