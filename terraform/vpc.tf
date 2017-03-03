module "vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc"

  name = "infra-demo-vpc"

  cidr = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
  ]

  azs = [
    "us-east-1a",
    "us-east-1c",
    "us-east-1d",
    "us-east-1e",
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
