output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.fast_food_user_pool.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.fast_food_user_pool.arn
}

output "user_pool_name" {
  description = "Name of the Cognito User Pool"
  value       = aws_cognito_user_pool.fast_food_user_pool.name
}

output "user_pool_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.fast_food_client.id
}
