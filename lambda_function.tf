data "archive_file" "lambda_package" {
  type = "zip"
  source_file = "code/lambda.py"
  output_path = "lambda.zip"
}

# Lambda Function
resource "aws_lambda_function" "lambda" {
  filename      = "lambda.zip"
  function_name = "lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda.lambda_handler"
  runtime       = "python3.12"
  timeout       = 10

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.app_data.name
    }
  }
  
}

# IAM Roles
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.lambda_exec.name

}