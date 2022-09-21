resource "aws_route53_zone" "dev" {
  name = "${var.host}.${var.domain}"
}

resource "aws_route53_record" "main" {
  zone_id = "${aws_route53_zone.dev.zone_id}"
  name    = "${aws_route53_zone.dev.name}"
  type    = "CNAME"
  ttl     = "300"

  records = [
    "${aws_elb.infra-demo-elb.dns_name}",
  ]
}

output "route53-dns" {
  value = "${aws_route53_zone.dev.name}"
}
