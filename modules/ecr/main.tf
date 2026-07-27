############################################
# ECR Repositories
############################################

# Create an ECR repository with image tag immutability and scan-on-push enabled
resource "aws_ecr_repository" "app" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE" # Prevents overwriting tags

  image_scanning_configuration {
    scan_on_push = true # Automatically scan for vulnerabilities
  }

  encryption_configuration {
    encryption_type = "AES256" # Or "KMS" for customer-managed keys
  }

  force_delete = true

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-${var.repository_name}"
  })
}

# Lifecycle Policies
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only the 20 most recent v-prefixed tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"] # Only apply to tags starting with "v"
          countType     = "imageCountMoreThan"
          countNumber   = 20
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3 # ensures older images were automatically removed, keeping the registry clean
        description  = "Keep only 10 images with any tag"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
