# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = var.tags
}

# API Gateway Resource /authenticate
resource "aws_api_gateway_resource" "authenticate" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "authenticate"
}

# API Gateway Method POST /authenticate
resource "aws_api_gateway_method" "authenticate_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.authenticate.id
  http_method   = "POST"
  authorization = var.authorization_type
}

# API Gateway Integration for /authenticate
resource "aws_api_gateway_integration" "authenticate" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.authenticate.id
  http_method             = aws_api_gateway_method.authenticate_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

# Lambda permission for API Gateway (restricted to /authenticate route)
resource "aws_lambda_permission" "authenticate_invoke" {
  statement_id  = "AllowInvokeAuthenticate"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/POST/authenticate"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeploy = sha1(jsonencode({
      res_auth  = aws_api_gateway_resource.authenticate.id
      meth_auth = aws_api_gateway_method.authenticate_post.id
      int_auth  = aws_api_gateway_integration.authenticate.id
    }))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.authenticate,
    aws_api_gateway_method.authenticate_post,
    aws_api_gateway_resource.authenticate,
  ]
}

resource "aws_api_gateway_stage" "api" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api.id
  stage_name    = var.stage_name
}

data "aws_partition" "current" {}
