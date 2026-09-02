terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.60.0"
    }
  }

  backend "s3" {
    bucket = "devops-nest-api-iac-state"
    key    = "state/terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}


resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "devops-nest-api-iac-state"

  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    IAC = "True"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket" {
  bucket = aws_s3_bucket.terraform_state_bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}
