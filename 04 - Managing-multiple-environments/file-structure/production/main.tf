terraform {
  # Assumes s3 bucket and dynamo DB table already set up

  backend "s3" {
    bucket         = "learn-terraform-user-bucket"
    key            = "04-managing-multiple-environments/production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "db_pass" {
  description = "password for database"
  type        = string
  sensitive   = true
}

locals {
  environment_name = "production"
}

module "web_app" {
  source = "../../../03 - Organisation and Modules/web-app-module"

  # Input Variables
  bucket_name      = "learn-terraform-web-app-data-${local.environment_name}"
  domain           = "jaycommits-devops.com"
  environment_name = local.environment_name
  instance_type    = "t2.small"
  create_dns_zone  = false
  db_name          = "${local.environment_name}mydb"
  db_user          = "foo"
  db_pass          = var.db_pass
}