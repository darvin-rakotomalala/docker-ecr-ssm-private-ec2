## Deploy Docker to EC2 Securely with GitHub Actions and AWS SSM

***

If your GitHub Actions deploy step still SSHes into an EC2 instance on port 22 using a stored private key, you have a
security liability sitting in your pipeline. An open SSH port is an attack surface. A long-lived SSH key stored in
GitHub Secrets is a credential that can leak. And you have zero native audit trail of what commands were executed on
that instance.

This project demonstrate how to replace all of that with AWS Systems Manager (SSM) Session Manager. No open inbound
ports. No SSH keys. Full command audit logging in CloudTrail. And we authenticate GitHub Actions to AWS using OpenID
Connect (OIDC) — meaning zero long-lived AWS credentials stored as secrets.

### Why AWS Elastic Container Registry (ECR) Made Sense

***

AWS Elastic Container Registry (ECR) fit the needs perfectly. Instead of using external registries, ECR offered:

* **Private and encrypted image storage**
* **Fast image pulls within AWS**, improving ECS/EKS startup times
* **Tight IAM integration**, removing extra credential systems
* **Automatic vulnerability scanning**
* **Simple lifecycle policies to control storage costs**

ECR gave the team a predictable, AWS-native solution where the images “just work” with the rest of their infrastructure.

### Architecture

***

**Core Components**

* **ECR repository** where the Docker image is pushed during the build stage
* **Docker image** for Static website app
* **VPC**: Virtual Private Cloud for networking
* **Subnet** private network
* **EC2 instance** target to manage must have the SSM agent installed
* **IAM role** instance role with policy to allow SSM to manage the instance and GitHub Actions OIDC Authentication
* **VPC endpoints** for SSM, EC2 messages, and SSM messages
* **Security groups** for EC2 and VPC endpoints
* **GitHub repository** with Actions enabled

### Why SSM Is More Secure Than SSH

***

SSH requires port 22 open in your security group. That port gets scanned constantly. Even with key-based auth, you’re
managing key distribution, rotation, and revocation manually. If a key leaks from GitHub Secrets, an attacker has direct
shell access.

SSM Session Manager flips the model entirely. The SSM Agent on the EC2 instance initiates an **outbound** HTTPS
connection to the SSM service endpoint. There are no inbound ports required — your security group can have zero inbound
rules. Authentication is handled via IAM roles, not SSH keys. Every command invocation is logged in AWS CloudTrail with
the full command text, the IAM principal that invoked it, the instance ID, and the execution result. This gives you an
audit trail that SSH simply cannot provide.

Additionally, you can restrict who can run commands on which instances using IAM policies with conditions on resource
tags — something impossible with SSH key distribution.

### Prerequisites

***

Before setting up the workflow, ensure the following:

* Terraform >= 1.14
* AWS provider ~> 5.0
* AWS Account
* AWS credentials with permissions to create VPC, IAM, EC2, and VPC Endpoint resources
* An ECR repository where your Docker image is pushed during the build stage
* EC2 instance with SSM Agent installed
* SSM Agent installed - Pre-installed on many AWS-provided AMIs, including Amazon Linux 2, Amazon Linux 2023, Ubuntu
  20.04+, and Windows Server 2016+
* An EC2 instance with Docker installed.
* IAM Role with ```AmazonSSMManagedInstanceCore``` attached
* AWS CLI installed
* AWS SSM Session Manager Plugin installed
* A GitHub repository with Actions enabled
* AWS CLI v2 installed locally for verification steps

### Implementation

***

**Step 1: Project structure**

```
docker-ecr-ssm-private-ec2/
├── AWS services study note         # AWS services study note
├── Documentation                   # Documentation of this project
└── modules/
    └── bootstrap/                  # Backend for Terraform state file
          ├── main.tf            
          ├── outputs.tf
          └── variables.tf
    └── ec2/                        # EC2 Instance server
          ├── main.tf            
          ├── outputs.tf
          └── variables.tf
    └── ecr/                        # ECR repository where Docker image is pushed
          ├── main.tf            
          ├── outputs.tf
          └── variables.tf
    └── iam/                        # IAM for Role and permission
          ├── main.tf               
          ├── outputs.tf
          └── variables.tf
    └── security-groups/            # Security groups
          ├── main.tf                
          ├── outputs.tf
          └── variables.tf
    └── vpc/                        # VPC for networking
          ├── main.tf
          ├── outputs.tf
          └── variables.tf
   ├── Screenshot verification      # Screenshot verification after success deployment
   ├── .gitignore                   # gitignore
   ├── backend.tf                   # Backend configuration for Terraform state file
   ├── data.tf                      # Data sources
   ├── locals.tf                    # locals for common_tags
   ├── main.tf                      # Main infrastructure resources
   ├── outputs.tf                   # Output values
   ├── terraform.tfvars             # Sample variable values
   ├── providers.tf                 # Terraform and AWS provider configuration
   ├── variables.tf                 # Input variables and defaults
   ├── .github/workflows/
      ├── deploy.yml                # Infrastructure deployement
      ├── checkov.yml               # Checkov workflows
```

**Step 2: Modules**

* **bootstrap** — Backend for Terraform state file to AWS S3
* **ecr** — An ECR repository where your Docker image is pushed during the build stage
* **vpc** — Provision VPC configuration and VPC Endpoint
* **security-groups** — The security group on the VPC endpoints needs to allow inbound HTTPS (port 443) from the
  instances
* **iam** — EC2 instances need an IAM role that allows the SSM agent to communicate with the Systems Manager service
  securely
* **ec2** — EC2 Instance with NO public IP, NO SSH key, NO inbound port 22

**Step 3: Outputs**

After successful deployment, the following outputs will be available:

- ```app_repository_url``` — Repository URL for the main app
- ```ecr_registry``` — ECR registry URL (account.dkr.ecr.region.amazonaws.com)
- ```ecr_repository``` — Name of the ECR repository
- ```push_commands_full``` — All push commands as shown in AWS Console
- ```iam_role_terraform_execution_arn``` — IAM role terraform execution ARN
- ```ec2_instance_id``` — Instance ID of EC2-SSM-SERVER (use this to start an SSM session)
- ```ec2_instance_private_ip``` — Private IP address of the EC2 instance
- ```ssm_connect_command``` — AWS CLI command to open a Session Manager shell on the instance

**Step 4: Deployment Workflow**

- ```checkov.yml``` — Automated security scanning framework using Checkov to detect Terraform misconfigurations at both
  repository and pull request (PR) levels
- ```infra.yml``` — Terraform workflow to provision infrastructure
- ```deploy_to_ecr.yml``` — Workflow to Build, tag, and push frontend image to Amazon ECR
- ```deploy_ec2_ssm.yml``` — Workflow to deploy securely Docker image in ECR to private EC2 via SSM.The key detail:
  ```aws ssm send-command``` is asynchronous. It returns a Command ID immediately. You then use
  ```aws ssm wait command-executed``` to block until execution finishes, and ```aws ssm get-command-invocation``` to
  retrieve the output and exit status.

Each push to the main branch triggered:

* Docker build
* Image tagging
* ECR authentication
* Automatic push to AWS

### Quick Start

***

- **Step 1 — Fork and clone**
  ```
  $ git clone https://github.com/darvin-rakotomalala/docker-ecr-ssm-private-ec2
  $ cd docker-ecr-ssm-private-ec2
  ```

- **Step 2 — Configure Terraform**<br>
  Edit ```docker-ecr-ssm-private-ec2/terraform.tfvars``` to match your target region and preferences. No secrets go
  here — just region and default tags.

- **Step 3 — Deploy infrastructure**

  ```
  $ docker-ecr-ssm-private-ec2
  $ terraform init
  $ terraform fmt -recursive
  $ terraform validate
  $ terraform plan -var-file="terraform.tfvars" -no-color -out=TFplan.JSON
  $ terraform apply -var-file="terraform.tfvars" -auto-approve
  ```

**Migration to remote backend**

- Add or activate backend configuration : ```backend.tf```
- Reinitialize to migrate state: ```terraform init -migrate-state```

### Verification

***

You can check the full documentation for **technical specifications** in ```Documentation``` directory and all
screenshot in ```Screenshot verification```.

- **Check the SSM endpoints**

- **Verifying the Deployment**

Beyond the pipeline check, you can verify manually from your local machine. Start an interactive SSM session (no SSH
needed):

```
# Install the Session Manager plugin first if you haven't
# https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

# Start session
aws ssm start-session --target i-0abc123def456789a

# Once connected:
docker ps
docker logs my-app --tail 20
```

You can also verify in CloudTrail. Search for the ```SendCommand``` event — it logs the IAM role ARN
(```ce-dev-github-actions-deploy-role```), the instance ID, the document name, and the command parameters. This is your
complete audit trail.

### Common Issues & Fixes

***

**❌ Instance Not Found in AWS SSM Session Manager**

* Ensure the IAM Role includes ```AmazonSSMManagedInstanceCore```.
* Verify SSM Agent is installed and running (```systemctl status amazon-ssm-agent```).
* Ensure the instance has outbound internet access or AWS SSM VPC Endpoints configured.
* **Verify SSM Agent Installation**
  ```
  # On Amazon Linux 2 (pre-installed)
  sudo systemctl status amazon-ssm-agent
  
  # If not installed
  sudo yum install -y amazon-ssm-agent
  sudo systemctl enable amazon-ssm-agent
  sudo systemctl start amazon-ssm-agent
  
  # On Ubuntu
  sudo snap install amazon-ssm-agent --classic
  sudo snap start amazon-ssm-agent
  
  # On Windows (PowerShell)
  Get-Service AmazonSSMAgent
  ```

**❌ Unit amazon-ssm-agent.service could not be found**

1. Check if it's installed as a snap: ```snap services amazon-ssm-agent```
2. If that returns a service listing, it's a snap installation. The correct commands are:

  ```
  sudo snap start amazon-ssm-agent
  sudo snap stop amazon-ssm-agent
  sudo snap restart amazon-ssm-agent
  ```

3. Check with:```systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service```

### Cleanup

***

To destroy all resources, run ```terraform destroy -var-file="terraform.tfvars" -auto-approve```

### Security and Cost Considerations

***

SSM Session Manager and SendCommand have no additional charge — you pay only for the EC2 instance and data transfer
you're already using. If you set up VPC endpoints for private subnets, those cost
approximately $0.01/GB processed plus ~$7.20/month per endpoint per AZ.

For a tighter security posture: enable SSM Session Manager logging to an S3 bucket and CloudWatch Logs group. This
captures full session output, not just API-level events. Combine this with an SCP or IAM boundary that denies
```ec2:AuthorizeSecurityGroupIngress``` on port 22 to ensure no one can accidentally re-open SSH across your
organization.

### Key Takeaways

***

* **AWS ECR simplified image management** with secure, fast, and fully managed container storage
* **Terraform ensured predictable infrastructure**, easy rollbacks, and reusable code
* **GitHub Actions automated builds and deployments** with zero AWS keys
* **Image scanning and lifecycle policies** improved security and reduced storage waste
* **The entire pipeline became cleaner, faster, and easier to operate**

### Summary

***

Combining **AWS ECR**, **Terraform**, and **GitHub Actions** creates a streamlined and reliable container workflow. This
setup ensures that infrastructure and images are managed consistently and securely, reduces manual overhead, accelerates
deployments, and improves operational efficiency. It provides a strong foundation for maintaining scalable, up-to-date,
and secure containerized applications, making it especially effective for fast-moving projects.

Replacing SSH with SSM for EC2 deployments eliminates an entire class of security risks — open ports, leaked keys,
unaudited access — with zero additional AWS cost. Combined with GitHub Actions OIDC, your entire pipeline runs without a
single long-lived credential.

- **Close port 22 permanently**. SSM uses outbound HTTPS only — no inbound rules needed.
- **Use OIDC, not stored AWS keys**. Short-lived tokens scoped to your repo and branch.
- **Scope IAM policies tightly**. Restrict SendCommand to specific instance IDs or tags.
- **Always verify**. Use get-command-invocation to confirm deployment status in your pipeline.
- **Enable CloudTrail and session logging**. Every command is auditable — use that advantage.
