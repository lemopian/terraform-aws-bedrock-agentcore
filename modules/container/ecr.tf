# ECR Repository for the container image
resource "aws_ecr_repository" "this" {
  name = local.ecr_repository_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags
}

# Get authorization credentials to push to ECR
data "aws_ecr_authorization_token" "token" {}
