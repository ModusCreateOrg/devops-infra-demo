terraform {
  #===================================================================
  # The S3 bucket and DyanmoDB table used here are created using
  # ./bootstrap project. See ./bootstrap/README.md for details.
  #===================================================================
  backend "s3" {
    bucket         = "moduscreate-devops-demo-tf-state-us-east-1"
    key            = "terraform-state.tfstate"
    dynamodb_table = "moduscreate-devops-demo-state-lock"
    region         = "us-east-1"
    encrypt        = "true"
    role_arn       = "arn:aws:iam::587267277416:role/terraform_sandbox_backend_admin"
  }
}

provider "template" {
  version = "~> 2.0"
}
