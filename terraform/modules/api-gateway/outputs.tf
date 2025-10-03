output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api.arn
}

output "api_invoke_base_url" {
  description = "Base URL do stage"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.${data.aws_partition.current.dns_suffix}/${aws_api_gateway_stage.api.stage_name}"
}

output "authenticate_url" {
  description = "URL de invocacao do POST /authenticate"
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.${data.aws_partition.current.dns_suffix}/${aws_api_gateway_stage.api.stage_name}/authenticate"
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api.execution_arn
}
