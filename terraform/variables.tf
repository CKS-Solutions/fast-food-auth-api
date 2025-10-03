variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile for resources"
  type        = string
  default     = "default" # or profile saved locally in aws cli
}

variable "expected_account_id" {
  description = "Expected AWS account ID"
  type        = string
  default     = "351323458664" # account-dev
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}
