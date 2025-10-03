variable "aws_region" {
  type = string
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "fast-food-api"
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "Fast Food API Gateway"
}

variable "endpoint_type" {
  description = "Type of API Gateway endpoint"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "EDGE", "PRIVATE"], var.endpoint_type)
    error_message = "Endpoint type must be REGIONAL, EDGE, or PRIVATE."
  }
}

variable "authorization_type" {
  description = "Authorization type for API Gateway methods"
  type        = string
  default     = "NONE"
}

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to integrate with"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
