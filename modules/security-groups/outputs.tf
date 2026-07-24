############################################
# Security Group outputs
############################################

output "ssm_security_group_id" {
  description = "ID of the SSM-SG security group shared by the EC2 instance and VPC endpoints"
  value       = aws_security_group.ssm.id
}

output "ssm_security_group_name" {
  description = "Name of the SSM-SG security group"
  value       = aws_security_group.ssm.name
}
