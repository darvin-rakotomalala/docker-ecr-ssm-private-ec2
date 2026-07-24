variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

variable "vpc_id" {
  description = "ID of the project VPC"
  type        = string
}
