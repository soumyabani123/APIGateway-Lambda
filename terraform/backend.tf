terraform {
  backend "s3" {
    bucket = "lambda-apigateway462" 
    key    = "API-GATEWAY/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }

}
