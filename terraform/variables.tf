# High level AWS variables
variable "aws_region" {
  description = "Amazon Region to use"
  default     = "us-east-1"
}

# Auto Scaling Groups related variables
variable "desired_capacity" {
  description = "Desired number of instances in AutoScaling Group"
  default     = 2
}

variable "min_size" {
  description = "Minimum number of instances in AutoScaling Group"
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in AutoScaling Group"
  default     = 3
}

# Route 53 related variables
variable "domain" {
  description = "Domain name hosted by Route 53"
  default     = "modus.app"
}

variable "host" {
  description = "Host name for Route 53 domain"
  default     = "devops-infra-demo"
}

# Public key variables - you can specify another file for the public key
# than the default
variable "public_key_file" {
  description = "Path to public key file (can contain ~)"
  default     = "~/.ssh/id_rsa.pub"
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

variable "aws_account_id_for_ami" {
  description = "AWS Account ID where AMIs live, if not the default"
  default     = ""
}

variable "ami_pattern" {
  description = "Amazon AWS AMI filename pattern"
  default     = "devops-infra-demo-centos-7*"
}

variable "virtualization_type" {
  description = "Virtualization type for AMIs"
  default     = "hvm"
}

variable "trusted_cidr_blocks" {
  description = "Trusted CIDR blocks, for ssh ingress"

  default = [
    "107.18.3.178/32",
  ]
}

variable "project_name" {
  description = "Project name"
  default     = "devops-infra-demo"
}
