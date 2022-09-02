terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = "~> 1.2.0"
}

provider "aws" {
  region = "${var.aws_region}"
}

module "bootstrap" {
  source = "trussworks/bootstrap/aws"

  region              = "${var.aws_region}"
  account_alias       = "${var.account_alias}"
  dynamodb_table_name = "${var.account_alias}-state-lock"
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "arn" {
  value = "${data.aws_caller_identity.current.arn}"
}

output "user_id" {
  value = "${data.aws_caller_identity.current.user_id}"
}

output "backend_details" {
  description = "Details of the S3 bucket and DynamoDB tables created for backend"
  value       = "${module.bootstrap}"
}
