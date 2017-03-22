resource "aws_key_pair" "infra-demo-pub" {
  key_name   = "infra-demo"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDDoc6IRfZwsS108F0eg158ghchkouBs6z28fWJe5G+EG+9fsonfYOtiZrsRMtCIMjt/IRayzF/u5jCVyClHJvmdNsgKC5DBngZYf21gk9WPHNocdKTkcVHkpS+E4sNJ/hznXHa3LZ8JsSKfuDAwGOJ0e3/gnUnpcaLoQbyL6kW2aa9oVaVwqZQnV5o3uH6rLI9GYtAOlIh5ogkaPwcWWOotROmQ5ZsFbY55bXq4aY+ZEKMqfkyxhneR7D9OmddTUKwMPsiHnIcI7+rFT+PtPM95Ep8bdyQdol05gVPAyNjeyJ8Fj6TU0Pb2VO8YY98KxPKh8WPUJGlKzciaYVRt5yxKQmwEjUODcak0V5CFDq6sEb6h8VhewQWIlkt7oMQhGei6mHWsJ29cmnwmVPTY+6gqx+DSKW6Q8EQf5fXOwhfeGfdCJ4WhsEYd8+o8RfPLNJlfsPj4RK73coww7V5UmmLp41qHEMklSqDMlDOEc3/35hqCLnF6vvLXLsC876UopS0xHRw6opvFfSe3FEKBnYRdHmgRncniUA9nDNbbZIi7pYftzwCPbRjKTmhtkyfy+ji0tGAY0Q8eHZzGALm6+GwCaPgSM0McRA+bpi66ghijaiUPMtKm58l9CPrhQuRdK1V1GeGfedgmbxdsb+aNNDkKAMc7fWzRLq4WBRB7uZkyw== infra-demo"
}

resource "aws_iam_role_policy" "consul-server-policy" {
  name = "consul-server-policy"
  role = "${aws_iam_role.consul-server-role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "consul-server-role" {
  name = "consul-server-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "consul-server-instances" {
  name  = "consul-server-instances"
  roles = ["${aws_iam_role.consul-server-role.name}"]
}

resource "aws_launch_configuration" "infra-demo-consul-server-lc" {
  name_prefix   = "infra-demo-consul-server-"
  image_id      = "ami-1ece7e08"
  instance_type = "t2.medium"

  security_groups = [
    "${module.vpc.default_security_group_id}",
    "${aws_security_group.consul.id}",
    "${aws_security_group.ssh.id}",
  ]

  iam_instance_profile = "${aws_iam_instance_profile.consul-server-instances.name}"

  key_name = "${aws_key_pair.infra-demo-pub.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "infra-demo-consul-server-asg" {
  name = "infra-demo-consul-server-asg"

  desired_capacity = "${var.desired_capacity}"
  min_size         = "${var.min_size}"
  max_size         = "${var.max_size}"

  launch_configuration = "${aws_launch_configuration.infra-demo-consul-server-lc.name}"
  health_check_type    = "EC2"

  vpc_zone_identifier = [
    "${module.vpc.public_subnets}",
  ]

  load_balancers = ["${aws_elb.infra-demo-elb.name}"]

  tag {
    key                 = "Name"
    value               = "infra-demo-consul"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "infra-demo"
    propagate_at_launch = true
  }

  tag {
    key                 = "consul-server"
    value               = "true"
    propagate_at_launch = true
  }
}
