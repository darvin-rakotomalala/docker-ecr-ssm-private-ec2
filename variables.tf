# ─── COMMON ───────────────────────────────────────────────────────────────────────
variable "primary_region" {
  description = "Primary region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "team_name" {
  description = "Team name"
  type        = string
}

variable "cost_center" {
  description = "Cost center"
  type        = string
}

variable "compliance" {
  description = "Compliance"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name"
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

# ─── ECR ───────────────────────────────────────────────────────────────────────
variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

/*
# ─── VPC ───────────────────────────────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the single private subnet"
  type        = string
}

# ─── EC2 ───────────────────────────────────────────────────────────────────────
variable "instance_type" {
  description = "EC2 instance type for the SSM-managed server"
  type        = string
}
*/