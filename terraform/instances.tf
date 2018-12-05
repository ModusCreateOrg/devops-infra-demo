resource "aws_key_pair" "infra-demo-pub" {
  key_name = "infra-demo"

  # Get the user's main primary public key and use that
  public_key = "${file(pathexpand(var.public_key_file))}"
}

# Idea for selecting node_app_ami adapted from:
# https://medium.com/@I_M_Harsh/build-and-deploy-using-jenkins-packer-and-terraform-40b2aafedaec
data "aws_ami" "node_app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_pattern}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["${var.virtualization_type}"]
  }

  owners = ["${var.aws_account_id_for_ami != "" ? var.aws_account_id_for_ami : data.aws_caller_identity.current.account_id}"]
}

data "template_file" "cloud-config" {
  template = "${file("cloud-config.yml")}"
}

resource "aws_iam_role" "CodeDeployServiceRole" {
  name               = "infra-demo-CodeDeployServiceRole"
  assume_role_policy = "${file("assume-role-policy.json")}"
}

resource "aws_iam_policy" "codedeploy-policy" {
  name        = "infra-demo-codedeploy-policy"
  description = "Policy allowing codedeploy to work"
  policy      = "${file("infra-demo-role-policy.json")}"
}

resource "aws_iam_policy_attachment" "codedeploy-attach" {
  name       = "infra-demo-codedeploy-attach"
  roles      = ["${aws_iam_role.CodeDeployServiceRole.name}"]
  policy_arn = "${aws_iam_policy.codedeploy-policy.arn}"
}

resource "aws_iam_instance_profile" "infra-demo-ip" {
  name  = "infra-demo-ip"
  roles = ["${aws_iam_role.CodeDeployServiceRole.name}"]
}

resource "aws_launch_configuration" "infra-demo-web-lc" {
  name_prefix   = "infra-demo-web-"
  image_id      = "${data.aws_ami.node_app_ami.id}"
  instance_type = "${var.instance_type}"

  security_groups = [
    "${module.vpc.default_security_group_id}",
    "${aws_security_group.web.id}",
    "${aws_security_group.ssh.id}",
  ]

  associate_public_ip_address = "${var.associate_public_ip_address}"
  key_name                    = "${aws_key_pair.infra-demo-pub.key_name}"

  iam_instance_profile = "${aws_iam_instance_profile.infra-demo-ip.name}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp2"
    delete_on_termination = true
  }

  enable_monitoring = true
  user_data         = "${data.template_file.cloud-config.rendered}"
}

resource "aws_autoscaling_group" "infra-demo-web-asg" {
  name = "infra-demo-asg"

  desired_capacity = "${var.desired_capacity}"
  min_size         = "${var.min_size}"
  max_size         = "${var.max_size}"

  launch_configuration = "${aws_launch_configuration.infra-demo-web-lc.name}"
  health_check_type    = "EC2"

  vpc_zone_identifier = [
    "${module.vpc.public_subnets}",
  ]

  load_balancers = ["${aws_elb.infra-demo-elb.name}"]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tag {
    key                 = "Name"
    value               = "infra-demo-web"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "infra-demo"
    propagate_at_launch = true
  }
}
