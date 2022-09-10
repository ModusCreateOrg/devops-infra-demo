/*
   We use jenkins to automate deployment with Terraform. Jenkins
   is set up in a different AWS account.

   This group of IAM resources allow jenkins to assume a role needed
   to deploy resources (and make changes to backend).
*/

data "aws_iam_policy_document" "terraform_backend_account_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::191447213457:role/jenkins-role"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "terraform_backend_role" {
  name               = "terraform_sandbox_backend_admin"
  assume_role_policy = data.aws_iam_policy_document.terraform_backend_account_policy.json
}

data "aws_iam_policy_document" "terraform_backend_role_policy_document" {
  statement {
    effect = "Allow"

    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${module.bootstrap.state_bucket}/*"]
  }

  statement {
    effect = "Allow"

    actions   = ["dynamodb:*"]
    resources = ["arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${module.bootstrap.dynamodb_table}"]
  }
}

resource "aws_iam_policy" "terraform_backend_role_policy" {
  name   = "terraform-backend-role-policy"
  policy = data.aws_iam_policy_document.terraform_backend_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "terraform_backend_attachment" {
  role       = aws_iam_role.terraform_backend_role.name
  policy_arn = aws_iam_policy.terraform_backend_role_policy.arn
}
