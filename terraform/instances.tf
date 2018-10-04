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

resource "aws_launch_configuration" "infra-demo-web-lc" {
  name_prefix   = "infra-demo-web-"
  image_id      = "${data.aws_ami.node_app_ami.id}"
  instance_type = "t2.micro"

  security_groups = [
    "${module.vpc.default_security_group_id}",
    "${aws_security_group.web.id}",
  ]

  #iam_instance_profile = "${aws_iam_instance_profile.?????.name}"

  key_name = "${aws_key_pair.infra-demo-pub.key_name}"
  lifecycle {
    create_before_destroy = true
  }
  ebs_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
  }
  enable_monitoring = true
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
