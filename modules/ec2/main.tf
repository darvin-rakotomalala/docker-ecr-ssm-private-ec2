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
  key_name = null

  iam_instance_profile = var.ssm_ec2_instance_profile_name

  user_data = <<-EOF
    #!/bin/bash
    set -ex

    # Redirect output to a log file for troubleshooting
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>&1)

    # -----------------------------------------------------------------
    # 1. AWS SSM Agent Configuration
    # -----------------------------------------------------------------
    # Ubuntu 24.04 AMI (Canonical) usually comes with SSM pre-installed,
    # but ensuring it's running and enabled:
    sudo systemctl enable amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent

    # -----------------------------------------------------------------
    # 2. Docker Installation (Official Canonical/Docker Repository)
    # -----------------------------------------------------------------
    # Update package index and install prerequisites
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg

    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up the stable Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine and associated plugins
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Enable and start Docker service
    systemctl enable docker
    systemctl start docker

    # Optional: If you plan to run container commands without root via SSM later,
    # add the default ubuntu user to the docker group (uncomment if needed):
    usermod -aG docker ubuntu
  EOF

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-EC2-SSM-Docker"
  })

  # Ensure the VPC endpoints exist before the instance tries to register with SSM
  depends_on = [var.vpc_endpoint_ssm, var.vpc_endpoint_ssmmessages, var.vpc_endpoint_ec2messages]
}
