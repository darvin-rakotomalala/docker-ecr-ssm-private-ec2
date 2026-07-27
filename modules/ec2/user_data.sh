#!/bin/bash
set -eux
# Log everything to a file for debugging via SSM
exec > >(tee /var/log/user-data.log) 2>&1

echo "### Updating packages ###"
apt-get update -y
apt-get upgrade -y

echo "### Installing prerequisites ###"
apt-get install -y ca-certificates curl gnupg lsb-release unzip

echo "### Installing AWS CLI v2 ###"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -o /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip
aws --version

echo "### Adding Docker GPG key ###"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "### Adding Docker repository ###"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "### Installing Docker Engine ###"
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "### Enabling Docker service ###"
systemctl enable docker
systemctl start docker

echo "### Adding ubuntu user to docker group ###"
usermod -aG docker ubuntu

echo "### Docker installation complete ###"
docker --version

echo "### User-data setup fully complete ###"
