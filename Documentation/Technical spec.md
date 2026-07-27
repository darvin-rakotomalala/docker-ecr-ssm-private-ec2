### Project — Deploy Docker to EC2 Securely with GitHub Actions and AWS SSM

**Objective** : This project demonstrates how to set up AWS Systems Manager (SSM) Session Manager with ```SendCommand```
to deploy Docker application in private EC2 Instance. No open inbound ports. No SSH keys. Full command audit logging in
CloudTrail. And we authenticate GitHub Actions to AWS using OpenID Connect (OIDC) — meaning zero long-lived AWS
credentials stored as secrets.

### Architecture

***

**Core Components**

* An **ECR repository** where your Docker image is pushed during the build stage
* **Docker image** for Static website app
* **VPC**: Virtual Private Cloud for networking
* **Subnet** private network
* **EC2 instance** target to manage must have the SSM agent installed
* **IAM role** instance role with policy to allow SSM to manage the instance
* **VPC endpoints** for SSM, EC2 messages, and SSM messages
* **Security groups** for EC2 and VPC endpoints
* **GitHub repository** with Actions enabled

![docker-ecr-ssm-private-ec2.png](../docker-ecr-ssm-private-ec2.png)

### Implementation with Terraform

***

**Step 1 - Create Docker file for frontend app**

- Create Docker file for HTML static website

**Step 2 - Create ECR Repositories**

- Create an ECR repository with image tag immutability and scan-on-push enabled
- Create lifecycle policy deletes untagged images older than 1 day, keeps the 10 most recent

**Step 3 - GitHub Actions workflow to build and deploy Docker file to ECR**

Build, tag, and push frontend image to Amazon ECR:
env:

    * AWS_REGION
    * ECR_REGISTRY
    * ECR_REPOSITORY_FRONTEND
    * role-to-assume for OIDC Authentication

**Step 4 - VPC configuration**

- CIDR block of the VPC 18.0.0.0/16
- Name: VPC-SSM
- One Availability zone
- Zero public subnet
- One private subnet
- No NAT gateway
- VPC Endpoint for SSM, SSM.MESSAGES, EC2.MESSAGES
- Enable DNS hostname
- Enable DNS resolution

**Step 5 - Create Security Group**

* Name: SSM-SG
* Security groups for EC2 and VPC endpoints
* The security group on the VPC endpoints needs to allow inbound HTTPS (port 443) from the instances

**Step 6 - Create an IAM Role for SSM-EC2 (EC2 Role for AWS Systems Manager access)**

* This role allows EC2 to communicate with SSM securely
* EC2 instances need an IAM role that allows the SSM agent to communicate with the Systems Manager service
* Name the role : EC2DockerDeployRole
* Attach the AWS managed policy : ```AmazonSSMManagedInstanceCore```
* Attach ECR read-only policy for pulling images : ```AmazonEC2ContainerRegistryReadOnly```
* On GitHub Actions OIDC Authentication Role attach a policy that allows SSM ```SendCommand``` and reading command
  results, scoped to an instance or tag

**Step 7: Create VPC endpoints for Private Instances without NAT**

* for_each = toset (["ssm", "ssmmessages", "ec2messages"]) create three VPC Endpoints category AWS services respectively
  the name below:
    * Name: VPCE-SSM
    * Name: VPCE-SSM-MESSAGES
    * Name: VPCE-EC2-MESSAGES
* For each VPC Endpoints type Interface, attach on VPC, private subnet, IPv4, Security groups and private dns enabled

**Step 8: Create an EC2 Instance with NO public IP, NO SSH key, NO inbound port 22**

* Name: EC2-SSM-SERVER, instance type "t3.medium"
* Choose an AMI (Ubuntu Server 24.04 LTS (HVM))
* No key pair
* Attach on VPC and private subnet
* Attach Security groups (SSM-SG)
* Attach IAM Role: SSM-EC2-Role. This ensures SSM has the necessary permissions.
  * Add User data below. This script installs and starts the SSM agent, on your instance:
    ```
    user_data = <<-EOF
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
    EOF
    ``` 

**Step 9 - GitHub Actions workflow to deploy Docker to private EC2 Securely with GitHub Actions and AWS SSM**

env:

* AWS_REGION
* ECR_REGISTRY
* ECR_REPOSITORY
* IMAGE_TAG
* INSTANCE_ID
* role-to-assume for OIDC Authentication
