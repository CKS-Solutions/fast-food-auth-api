# Cognito User Pool
resource "aws_cognito_user_pool" "fast_food_user_pool" {
  name = var.user_pool_name

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  schema {
    name                     = "cpf"
    attribute_data_type      = "String"
    mutable                  = false
    developer_only_attribute = false
  }

  username_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

  auto_verified_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Código de verificação - Fast Food"
    email_message        = "Seu código de verificação é {####}"
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  user_pool_add_ons {
    advanced_security_mode = "OFF"
  }

  tags = var.tags
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "fast_food_client" {
  name         = "${var.user_pool_name}-client"
  user_pool_id = aws_cognito_user_pool.fast_food_user_pool.id

  generate_secret                               = false
  prevent_user_existence_errors                 = "ENABLED"
  enable_token_revocation                       = true
  enable_propagate_additional_user_context_data = false

  explicit_auth_flows = [
    "ADMIN_NO_SRP_AUTH",
    "USER_PASSWORD_AUTH"
  ]
}
