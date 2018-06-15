resource "aws_key_pair" "infra-demo-pub" {
  key_name   = "infra-demo"
  # Get the user's main primary public key and use that
  public_key = "${file(pathexpand(var.public_key_file))}"
}

resource "aws_launch_configuration" "infra-demo-web-lc" {
  name_prefix   = "infra-demo-web-"
  image_id      = "${var.ami}"
  instance_type = "t2.medium"

  security_groups = [
    "${module.vpc.default_security_group_id}",
    "${aws_security_group.web.id}",
  ]

  #iam_instance_profile = "${aws_iam_instance_profile.?????.name}"

  key_name = "${aws_key_pair.infra-demo-pub.key_name}"
  lifecycle {
    create_before_destroy = true
  }
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
