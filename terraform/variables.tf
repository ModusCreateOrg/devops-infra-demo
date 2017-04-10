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
  default     = "example.com"
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

variable "google_project" {
  description = "Google project for assets"
  default = "example-media"
}

variable "ami" {
  description = "Amazon AWS AMI to use"
  default = "ami-f0768de6"
}
