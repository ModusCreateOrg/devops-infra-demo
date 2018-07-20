module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"

  name = "infra-demo-vpc"

  cidr = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]

  azs = [
    "${var.zone}a",
    "${var.zone}b",
    "${var.zone}c"
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
