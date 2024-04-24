terraform {
  required_version = "~>0.13.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25.0"
    }
  }
  
  backend "s3" {
    bucket = "dce-terraform-state-bucket"
    key = "terraform.state"
    region = "eu-central-1"
    dynamodb_table = "dce-terraform-state-dynamo-table"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Current AWS Account User
data "aws_caller_identity" "current" {
}

locals {
  account_id            = data.aws_caller_identity.current.account_id
  sns_encryption_key_id = "alias/aws/sns"
}
