data "aws_route53_zone" "modus" {
  name = "moduscreate.com."
}

resource "aws_route53_record" "main" {
  zone_id = "${data.aws_route53_zone.modus.zone_id}"
  name = "devops-nyc-demo.moduscreate.com"
  type = "CNAME"
  ttl = "300"
  records = [
  	"${aws_elb.infra-demo-elb.dns_name}"
  ]
}