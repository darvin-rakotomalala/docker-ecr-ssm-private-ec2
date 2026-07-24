############################################
# ECR Outputs
############################################

# Export repository URLs for use in other modules and CI/CD pipelines:
output "app_repository_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "Repository URL for the main app"
}

output "ecr_repository" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.app.name
}

output "ecr_registry" {
  description = "ECR registry URL (account.dkr.ecr.region.amazonaws.com)"
  value       = element(split("/", aws_ecr_repository.app.repository_url), 0)
}

locals {
  registry_url = "${var.current_account_id}.dkr.ecr.${var.primary_region}.amazonaws.com"
}

output "login_command" {
  description = "Command to authenticate Docker to ECR"
  value       = "aws ecr get-login-password --region ${var.primary_region} | docker login --username AWS --password-stdin ${local.registry_url}"
}

output "build_command" {
  description = "Command to build the Docker image"
  value       = "docker build -t ${aws_ecr_repository.app.name} ."
}

output "tag_command" {
  description = "Command to tag the image for ECR"
  value       = "docker tag ${aws_ecr_repository.app.name}:latest ${aws_ecr_repository.app.repository_url}:latest"
}

output "push_command" {
  description = "Command to push the image to ECR"
  value       = "docker push ${aws_ecr_repository.app.repository_url}:latest"
}

output "push_commands_full" {
  description = "All push commands as shown in AWS Console"
  value       = <<-EOT
    # Retrieve an authentication token and authenticate your Docker client to your registry
    aws ecr get-login-password --region ${var.primary_region} | docker login --username AWS --password-stdin ${local.registry_url}

    # Build your Docker image using the following command
    docker build -t ${aws_ecr_repository.app.name} .

    # Tag your image so you can push the image to this repository
    docker tag ${aws_ecr_repository.app.name}:latest ${aws_ecr_repository.app.repository_url}:latest

    # Push this image to your newly created AWS repository
    docker push ${aws_ecr_repository.app.repository_url}:latest
  EOT
}
