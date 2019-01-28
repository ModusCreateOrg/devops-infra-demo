resource "aws_secretsmanager_secret" "newrelic_license" {
  name = "newrelic_license"
}

resource "aws_secretsmanager_secret_version" "newrelic_license" {
  secret_id     = "${aws_secretsmanager_secret.newrelic_license.id}"
  secret_string = "${var.newrelic_license_key}"
}
