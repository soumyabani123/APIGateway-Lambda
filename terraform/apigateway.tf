resource "aws_api_gateway_rest_api" "my_api" {
  name = "my-api"
  description = "API Gateway"
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part = "dev"
}

# API Gateway Integration
resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.Authorizer.id
}

resource "aws_api_gateway_integration" "Integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:${aws_api_gateway_rest_api.my_api.id}/*/${aws_api_gateway_method.post.http_method}${aws_api_gateway_resource.root.path}"
}

resource "aws_api_gateway_method_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "proxy" {

  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.proxy.status_code

  depends_on = [
    aws_api_gateway_method.post,
    aws_api_gateway_integration.Integration
  ]

}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.Integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.my_api.id
  #stage_name = "dev"
}


