resource "aws_iam_role" "infra-demo" {
  name = "tf-infra-demo-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# attach AWS managed policy called AWSCodeDeployRole
# required for deployments which are to an EC2 compute platform
resource "aws_iam_role_policy_attachment" "tf-codedeploy-role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = "${aws_iam_role.infra-demo.name}"
}

resource "aws_codedeploy_app" "infra-demo" {
  name = "tf-infra-demo-app"
}

resource "aws_codedeploy_deployment_group" "infra-demo" {
  app_name              = "${aws_codedeploy_app.infra-demo.name}"
  deployment_group_name = "dev"
  service_role_arn      = "${aws_iam_role.infra-demo.arn}"

  autoscaling_groups = [
    "infra-demo-asg",
  ]

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  alarm_configuration {
    alarms  = ["tf-infra-demo-alarm"]
    enabled = true
  }
}
