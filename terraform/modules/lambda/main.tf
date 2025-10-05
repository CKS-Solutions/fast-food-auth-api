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
      zip -r /tmp/lambda_function.zip .
    EOT
  }
}

# Lambda function
resource "aws_lambda_function" "api_lambda" {
  filename         = "/tmp/lambda_function.zip"
  function_name    = var.function_name
  role             = var.lambda_role_arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("/tmp/lambda_function.zip")
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

  depends_on = [null_resource.lambda_build]
}
