variable "lambda_role_name" {
  description = "Name of the IAM role for Lambda"
  type        = string
  default     = "fast-food-lambda-role"
}

variable "enable_vpc_access" {
  description = "Enable VPC access for Lambda"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
