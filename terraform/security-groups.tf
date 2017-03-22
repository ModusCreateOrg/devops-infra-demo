resource "aws_security_group" "outbound" {
  name        = "infra-demo-outbound"
  description = "Grants instances all outbound access"
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Project = "infra-demo"
  }
}

resource "aws_security_group" "ssh" {
  name        = "infra-demo-ssh"
  description = "Grants access to ssh"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "107.18.3.178/32",
      "72.192.212.18/32", # matt@moduscreate.com
      "97.65.133.42/32",  # Modus HQ Level 3
      "69.255.26.188/32", # Modus HQ Comcast
    ]
  }

  tags {
    Project = "infra-demo"
  }
}

resource "aws_security_group" "consul" {
  name        = "infra-demo-consul"
  description = "Allows access to consul ports"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 8300
    to_port   = 8300
    protocol  = "tcp"

    self = true
  }

  ingress {
    from_port = 8301
    to_port   = 8302
    protocol  = "tcp"

    self = true
  }

  ingress {
    from_port = 8301
    to_port   = 8302
    protocol  = "udp"

    self = true
  }

  ingress {
    from_port = 8500
    to_port   = 8501
    protocol  = "tcp"

    self = true
  }

  ingress {
    from_port = 8600
    to_port   = 8600
    protocol  = "tcp"

    self = true
  }

  tags {
    Project = "infra-demo"
  }
}

resource "aws_security_group" "web" {
  name        = "infra-demo-web"
  description = "Allows access to common web ports"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0", # Everyone
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0", # Everyone
    ]
  }

  tags {
    Project = "infra-demo"
  }
}

resource "aws_security_group" "icmp" {
  name        = "infra-demo-icmp"
  description = "Allows access to ping"
  vpc_id      = "${module.vpc.vpc_id}"

  # Allow ICMP echo
  # https://github.com/hashicorp/terraform/issues/1313#issuecomment-107619807
  ingress {
    from_port = -1
    to_port   = -1
    protocol  = "icmp"
    self      = true
  }

  tags {
    Project = "infra-demo"
  }
}
