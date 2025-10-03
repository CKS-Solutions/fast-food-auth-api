variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "fast-food-api"
}

variable "lambda_role_arn" {
  description = "ARN of the IAM role for Lambda"
  type        = string
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs18.x"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default = {
    NODE_ENV = "development"
  }
}

variable "lambda_code" {
  description = "Lambda function code"
  type        = string
  default     = <<EOF
exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS'
        },
        body: JSON.stringify({
            message: 'Hello from Fast Food API!',
            timestamp: new Date().toISOString(),
            path: event.path,
            method: event.httpMethod
        })
    };
};
EOF
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
