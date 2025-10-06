variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
  default     = "fast-food-user-pool"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
