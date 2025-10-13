resource "aws_lambda_function" "api_lambda" {
  function_name = var.function_name

  s3_bucket = var.lambda_bucket_id
  s3_key    = var.lambda_struct.lambda_auth_key

  runtime = var.runtime
  handler = "main"

  source_code_hash = var.lambda_struct.lambda_auth_base64sha256

  timeout     = var.timeout
  memory_size = var.memory_size

  role = var.lambda_role_arn

  environment {
    variables = merge(var.environment_variables, {
      COGNITO_USER_POOL_ID = var.cognito_user_pool_id
      COGNITO_CLIENT_ID    = var.cognito_client_id
    })
  }

  tags = var.tags
}
