# ─── COMMON ───────────────────────────────────────────────────────────────────────
# Adjust as needed
primary_region = "us-east-1"
environment    = "dev"
project_name   = "ce"
team_name      = "training"
cost_center    = "engineering"
compliance     = "internal"
github_org     = "darvin-rakotomalala"
github_repo    = "docker-ecr-ssm-private-ec2"
bucket_name    = "ce-dev-terraform-state-69127"

repository_name = "my-static-site"

vpc_cidr            = "18.0.0.0/16"
private_subnet_cidr = "18.0.1.0/24"
public_subnet_cidr  = "18.0.2.0/24"
instance_type       = "t3.medium"
