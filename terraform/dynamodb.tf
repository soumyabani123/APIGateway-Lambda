resource "aws_dynamodb_table" "app_data" {

  name         = "AppData"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "AppName"
    type = "S"
  }

  attribute {
    name = "CreateDate"
    type = "S"  
  }

  hash_key  = "AppName"
  range_key = "CreateDate"

}