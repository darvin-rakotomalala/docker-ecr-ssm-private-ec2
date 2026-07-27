############################################
# EC2 Instance outputs
############################################

output "ec2_instance_id" {
  description = "Instance ID of EC2-SSM-SERVER (use this to start an SSM session)"
  value       = aws_instance.ssm_server.id
}

output "target_instance_id" {
  description = "Instance ID of EC2-SSM-SERVER (use this to start an SSM session)"
  value       = aws_instance.ssm_server.id
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ssm_server.public_ip
}

output "ec2_instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.ssm_server.private_ip
}

output "ec2_instance_ami_id" {
  description = "AMI ID used (latest Ubuntu Server 24.04 LTS)"
  value       = data.aws_ami.ubuntu_24_04.id
}

output "ssm_connect_command" {
  description = "AWS CLI command to open a Session Manager shell on the instance"
  value       = "aws ssm start-session --target ${aws_instance.ssm_server.id} --region ${var.primary_region}"
}
