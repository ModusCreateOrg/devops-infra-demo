module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> v1.0"

  name = "infra-demo-vpc"

  cidr = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c",
  ]

  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true

  tags {
    "Terraform"   = "true"
    "Environment" = "demo"
    "Project"     = "infra-demo"
  }
}
