resource "aws_lambda_function" "api_lambda" {
  function_name    = var.function_name

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_object.lambda_auth.key

  runtime          = var.runtime
  handler          = "index.handler"

  source_code_hash = data.archive_file.lambda_auth.output_base64sha256

  timeout          = var.timeout
  memory_size      = var.memory_size

  role             = var.lambda_role_arn

  environment {
    variables = merge(var.environment_variables, {
      COGNITO_USER_POOL_ID = var.cognito_user_pool_id
      COGNITO_CLIENT_ID    = var.cognito_client_id
    })
  }

  tags = var.tags
}
