data "aws_route53_zone" "dev" {
  name = "${var.domain}."
}

resource "aws_route53_record" "main" {
  zone_id = "${data.aws_route53_zone.dev.zone_id}"
  name    = "${var.host}.${var.domain}"
  type    = "CNAME"
  ttl     = "300"

  records = [
    "${aws_elb.infra-demo-elb.dns_name}",
  ]
}
