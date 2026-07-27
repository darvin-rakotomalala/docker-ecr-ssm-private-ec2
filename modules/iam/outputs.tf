############################################
# IAM Role outputs
############################################

output "iam_role_terraform_execution_arn" {
  description = "IAM role terraform execution ARN"
  value       = aws_iam_role.terraform_execution.arn
}

output "ssm_ec2_role_name" {
  description = "Name of the IAM role attached to the EC2 instance"
  value       = aws_iam_role.ssm_ec2_role.name
}

output "ssm_ec2_role_arn" {
  description = "ARN of the SSM-EC2-Role IAM role"
  value       = aws_iam_role.ssm_ec2_role.arn
}

output "ssm_ec2_instance_profile_name" {
  description = "Name of the instance profile attached to the EC2 instance"
  value       = aws_iam_instance_profile.ssm_ec2_profile.name
}

output "ssm_ec2_instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = aws_iam_instance_profile.ssm_ec2_profile.arn
}
