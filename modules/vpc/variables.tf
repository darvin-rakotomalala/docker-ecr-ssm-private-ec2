variable "primary_region" {
  description = "Primary region"
  type        = string
}

variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the single public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the single private subnet"
  type        = string
}

variable "data_az_available_names" {
  description = "Availability Zones available in current region"
  type        = string
}

variable "ssm_security_group_id" {
  description = "ID of Security group for SSM"
  type        = set(string)
}
