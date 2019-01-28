# Thanks @marcosdiez for the suggestion
# This makes it super-clear which AWS account, arn, and user_id are in use
# in a way that can be conveniently tracked in the output of CI tools
provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.57"
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
