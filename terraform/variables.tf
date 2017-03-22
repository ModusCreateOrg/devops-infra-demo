variable "desired_capacity" {
  description = "Desired number of instances in AutoScaling Group"
  default     = 3
}

variable "min_size" {
  description = "Minimum number of instances in AutoScaling Group"
  default     = 3
}

variable "max_size" {
  description = "Maximum number of instances in AutoScaling Group"
  default     = 4
}
