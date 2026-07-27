#########################################################
# BACKEND
#########################################################

module "bootstrap" {
  source        = "./modules/bootstrap"
  naming_prefix = local.naming_prefix
  common_tags   = local.common_tags
  bucket_name   = var.bucket_name
}

#########################################################
# ECR
#########################################################

module "ecr" {
  source             = "./modules/ecr"
  naming_prefix      = local.naming_prefix
  common_tags        = local.common_tags
  current_account_id = data.aws_caller_identity.current.account_id
  primary_region     = var.primary_region
  repository_name    = var.repository_name
}

#########################################################
## IAM
#########################################################

module "iam" {
  source             = "./modules/iam"
  current_account_id = data.aws_caller_identity.current.account_id
  naming_prefix      = local.naming_prefix
  common_tags        = local.common_tags
  github_org         = var.github_org
  github_repo        = var.github_repo
  primary_region     = var.primary_region
  ec2_instance_id    = module.ec2.ec2_instance_id
  target_instance_id = module.ec2.target_instance_id
}

#########################################################
## VPC
#########################################################

module "vpc" {
  source                  = "./modules/vpc"
  common_tags             = local.common_tags
  naming_prefix           = local.naming_prefix
  primary_region          = var.primary_region
  vpc_cidr                = var.vpc_cidr
  ssm_security_group_id   = [module.security-groups.ssm_security_group_id]
  data_az_available_names = data.aws_availability_zones.available.names[0]
  private_subnet_cidr     = var.private_subnet_cidr
  public_subnet_cidr      = var.public_subnet_cidr
}

#########################################################
## SECURITY GROUPS
#########################################################

module "security-groups" {
  source        = "./modules/security-groups"
  common_tags   = local.common_tags
  naming_prefix = local.naming_prefix
  vpc_id        = module.vpc.vpc_id
}

#########################################################
## EC2
#########################################################

module "ec2" {
  source                        = "./modules/ec2"
  primary_region                = var.primary_region
  naming_prefix                 = local.naming_prefix
  common_tags                   = local.common_tags
  instance_type                 = var.instance_type
  private_subnet_id             = module.vpc.private_subnet_id
  ssm_ec2_instance_profile_name = module.iam.ssm_ec2_instance_profile_name
  ssm_security_group_id         = [module.security-groups.ssm_security_group_id]
  vpc_endpoint_ssm              = module.vpc.vpc_endpoint_ssm
  vpc_endpoint_ssmmessages      = module.vpc.vpc_endpoint_ssmmessages
  vpc_endpoint_ec2messages      = module.vpc.vpc_endpoint_ec2messages
}
