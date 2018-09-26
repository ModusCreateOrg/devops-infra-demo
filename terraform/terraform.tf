terraform {
 backend "s3" {
 encrypt = true
 # We can't specify parameterized config here but if we could it would look like:
 # bucket = "tf-state.${project_name}.${aws_region}.${data.aws_caller_identity.current.account_id}"
 # dynamodb_table = "TerraformStatelock-${project_name}"
 bucket = "my-terraform-bucket"
 dynamodb_table = "TerraformStatelock"
 region = "us-east-1"
 key = "terraform.tfstate"
 }
}
