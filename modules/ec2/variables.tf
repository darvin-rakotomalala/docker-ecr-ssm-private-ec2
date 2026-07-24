variable "primary_region" {
  description = "Primary region"
  type        = string
}

variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

variable "instance_type" {
  description = "EC2 instance type for the SSM-managed server"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}

variable "ssm_security_group_id" {
  description = "ID of the SSM-SG security group shared by the EC2 instance and VPC endpoints"
  type        = set(string)
}

variable "ssm_ec2_instance_profile_name" {
  description = "Name of the instance profile attached to the EC2 instance"
  type        = string
}

variable "vpc_endpoint_ssm" {
  description = "VPC endpoint resource 0"
  type        = string
}

variable "vpc_endpoint_ssmmessages" {
  description = "VPC endpoint resource 1"
  type        = string
}

variable "vpc_endpoint_ec2messages" {
  description = "VPC endpoint resource 2"
  type        = string
}
