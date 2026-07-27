############################################
# EC2 Instance
############################################

data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "ssm_server" {
  ami                         = data.aws_ami.ubuntu_24_04.id
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = var.ssm_security_group_id
  associate_public_ip_address = false
  # No SSH key pair - access is exclusively via SSM Session Manager
  key_name             = null
  iam_instance_profile = var.ssm_ec2_instance_profile_name

  user_data_base64 = filebase64("${path.module}/user_data.sh")

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-EC2-SSM-Docker"
  })

  # Ensure the VPC endpoints exist before the instance tries to register with SSM
  depends_on = [var.vpc_endpoint_ssm, var.vpc_endpoint_ssmmessages, var.vpc_endpoint_ec2messages]
}
