resource "aws_dynamodb_table" "terraform_state_lock" {
  hash_key = "LockID"
  name     = "${var.project_name}-terraform-state-dynamo-table"
  billing_mode = "PAY_PER_REQUEST"
  deletion_protection_enabled = true
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  server_side_encryption {
    enabled = true
  }
}
