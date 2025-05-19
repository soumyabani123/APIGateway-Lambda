resource "aws_cognito_user_pool" "pool" {
  name = "cognito_pool"
}

resource "aws_cognito_user_pool_client" "client" {

  name = "client"
  allowed_oauth_flows_user_pool_client = true
  generate_secret = false
  allowed_oauth_scopes = ["aws.cognito.signin.user.admin"]
  allowed_oauth_flows = ["implicit", "code"]
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
  supported_identity_providers = ["COGNITO"]

  user_pool_id = aws_cognito_user_pool.pool.id
  callback_urls = ["https://api.testdevops.com"]

}

resource "aws_cognito_user" "siemens" {

  user_pool_id = aws_cognito_user_pool.pool.id
  username = "siemens"
  password = "Test@123"

}

resource "aws_api_gateway_authorizer" "Authorizer" {

  name = "my_apig_authorizer"
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  type = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.pool.arn]

}

