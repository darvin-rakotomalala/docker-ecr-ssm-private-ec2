variable "primary_region" {
  description = "Primary region"
  type        = string
}

variable "naming_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "common_tags" {}

variable "current_account_id" {
  description = "Current account ID"
  type        = string
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository"
  type        = string
}

variable "ec2_instance_id" {
  description = "Instance ID of EC2-SSM-SERVER (use this to start an SSM session)"
  type        = string
}

variable "target_instance_id" {
  description = "Instance ID of EC2-SSM-SERVER (use this to start an SSM session)"
  type        = string
}
