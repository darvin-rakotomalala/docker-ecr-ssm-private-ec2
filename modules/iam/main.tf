#######################################################
# IAM role for Terraform execution (used in CI/CD)
#######################################################

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "terraform_execution" {
  name = "${var.naming_prefix}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.current_account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          }
        }
      }
    ]
  })

  # Maximum session duration (1 hour for Terraform runs)
  max_session_duration = 3600

  tags = merge(var.common_tags, {
    Name    = "${var.naming_prefix}-github-actions-oidc"
    Type    = "github-actions-role"
    Purpose = "oidc-provider-deployment"
  })
}

resource "aws_iam_role_policy_attachment" "terraform_execution_admin" {
  role = aws_iam_role.terraform_execution.name
  # Bad: Overly permissions
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # Scope down in production. Specific permissions for specific resources
}

/*
resource "aws_iam_role_policy" "ssm_send_command" {
  name = "${var.naming_prefix}-ssm-send-command-policy"
  role = aws_iam_role.terraform_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSSMSendCommandToInstance"
        Effect = "Allow"
        Action = [
          "ssm:SendCommand"
        ]
        Resource = [
          # Scope execution to the target EC2 instance
          "arn:aws:ec2:${var.primary_region}:${var.current_account_id}:instance/${var.ec2_instance_id}",
          # Scope execution to specific SSM Documents (e.g., shell/powershell scripts)
          "arn:aws:ssm:${var.primary_region}::document/AWS-RunShellScript",
          "arn:aws:ssm:${var.primary_region}::document/AWS-RunPowerShellScript"
        ]
      },
      {
        Sid    = "AllowSSMReadCommandResults"
        Effect = "Allow"
        Action = [
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:ListCommands"
        ]
        # GetCommandInvocation & ListCommands do not support resource-level permissions (must use *)
        Resource = "*"
      }
    ]
  })
}

############################################
# IAM Role for SSM-EC2
############################################

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_ec2_role" {
  name               = "${var.naming_prefix}-EC2DockerDeployRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-EC2DockerDeployRole"
  })
}

# Attach AWS Systems Manager Core policy
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ssm_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach AWS ECR Read-Only policy for pulling Docker images
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ssm_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Instance profile required to attach the IAM role to the EC2 instance
resource "aws_iam_instance_profile" "ssm_ec2_profile" {
  name = "${var.naming_prefix}-EC2DockerDeployRole-Profile"
  role = aws_iam_role.ssm_ec2_role.name
}
*/
