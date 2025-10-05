# Lambda function
resource "aws_lambda_function" "api_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.function_name
  role             = var.lambda_role_arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size

  environment {
    variables = merge(var.environment_variables, {
      COGNITO_USER_POOL_ID = var.cognito_user_pool_id
      COGNITO_CLIENT_ID    = var.cognito_client_id
    })
  }

  tags = var.tags
}

# Build Lambda package with dependencies
resource "null_resource" "lambda_build" {
  triggers = {
    source_hash  = filemd5("${path.module}/../../../src/auth/index.js")
    package_hash = filemd5("${path.module}/../../../src/auth/package.json")
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}/../../../src/auth
      npm install --production
      zip -r ../../../../lambda_function.zip .
    EOT
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "/tmp/lambda_function.zip"
  output_path = "/tmp/lambda_function.zip"
  depends_on  = [null_resource.lambda_build]
}
