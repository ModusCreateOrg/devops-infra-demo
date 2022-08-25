terraform {
  #===================================================================
  # The S3 bucket and DyanmoDB table used here are created using
  # ./bootstrap project. See ./bootstrap/README.md for details.
  #===================================================================
  backend "s3" {
    bucket         = "${var.backend_account_alias}-tf-state-us-east-1"
    key            = "terraform-state.tfstate"
    dynamodb_table = "${var.backend_account_alias}-state-lock"
    region         = "${var.aws_region}"
    encrypt        = "true"
  }
}

provider "template" {
  version = "~> 2.0"
}
