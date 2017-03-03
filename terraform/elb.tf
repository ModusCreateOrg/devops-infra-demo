resource "aws_elb" "infra-demo-elb" {
  name = "infra-demo-elb"

  subnets = ["${module.vpc.public_subnets}"]

  security_groups = [
    "${module.vpc.default_security_group_id}",
    "${aws_security_group.web.id}",
  ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name    = "infra-demo-elb"
    Project = "infra-demo"
  }
}

output "elb-dns" {
  value = "${aws_elb.infra-demo-elb.dns_name}"
}
