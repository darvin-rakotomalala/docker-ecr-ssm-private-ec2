output "iam_role_terraform_execution_arn" {
  description = "IAM role terraform execution ARN"
  value       = module.iam.iam_role_terraform_execution_arn
}

output "app_repository_url" {
  value       = module.ecr.app_repository_url
  description = "Repository URL for the main app"
}

output "ecr_repository" {
  description = "Name of the ECR repository"
  value       = module.ecr.ecr_repository
}

output "ecr_registry" {
  description = "ECR registry URL (account.dkr.ecr.region.amazonaws.com)"
  value       = module.ecr.ecr_registry
}

output "push_commands_full" {
  description = "All push commands as shown in AWS Console"
  value       = module.ecr.push_commands_full
}

output "ec2_instance_id" {
  description = "Instance ID of EC2-SSM-SERVER (use this to start an SSM session)"
  value       = module.ec2.ec2_instance_id
}

output "ec2_instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2.ec2_instance_private_ip
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.ec2_instance_public_ip
}

output "ssm_connect_command" {
  description = "AWS CLI command to open a Session Manager shell on the instance"
  value       = "aws ssm start-session --target ${module.ec2.ec2_instance_id} --region ${var.primary_region}"
}
