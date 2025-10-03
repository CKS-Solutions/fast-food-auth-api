terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

data "aws_caller_identity" "me" {}

resource "null_resource" "assert_account" {
  lifecycle {
    precondition {
      condition     = data.aws_caller_identity.me.account_id == var.expected_account_id
      error_message = "AWS account incorreta. Esperado ${var.expected_account_id}, atual ${data.aws_caller_identity.me.account_id}."
    }
  }
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  lambda_role_name  = "fast-food-lambda-role"
  enable_vpc_access = false
  tags = {
    Environment = var.environment
    Project     = "fast-food"
  }
}

# Lambda Module
module "lambda" {
  source = "./modules/lambda"

  function_name   = "fast-food-api"
  lambda_role_arn = module.iam.lambda_role_arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 30
  memory_size     = 128
  environment_variables = {
    NODE_ENV = var.environment
  }
  tags = {
    Environment = var.environment
    Project     = "fast-food"
  }
}

# API Gateway Module
module "api_gateway" {
  source = "./modules/api-gateway"

  api_name             = "fast-food-api"
  api_description      = "Fast Food API Gateway"
  endpoint_type        = "REGIONAL"
  authorization_type   = "NONE"
  stage_name           = var.environment
  lambda_function_name = module.lambda.lambda_function_name
  lambda_invoke_arn    = module.lambda.lambda_invoke_arn
  aws_region           = var.aws_region
  tags = {
    Environment = var.environment
    Project     = "fast-food"
  }
}

# Outputs
output "api_gateway_base_url" {
  description = "Base URL of the API Gateway"
  value       = module.api_gateway.api_invoke_base_url
}

output "authenticate_url" {
  description = "URL for POST /authenticate endpoint"
  value       = module.api_gateway.authenticate_url
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.lambda_function_arn
}
