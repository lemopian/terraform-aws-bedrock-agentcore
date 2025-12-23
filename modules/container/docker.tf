# Configure Docker provider with ECR credentials
provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

# Build Docker image
resource "docker_image" "this" {
  name = "${replace(data.aws_ecr_authorization_token.token.proxy_endpoint, "https://", "")}/${local.ecr_repository_name}:${var.image_tag}"

  build {
    context    = var.container_source_path
    dockerfile = local.dockerfile_path
  }

  platform = var.docker_platform

  # Force rebuild when source files change
  triggers = {
    dir_sha1 = sha1(join("", [
      for f in fileset(var.container_source_path, "**") : filesha1("${var.container_source_path}/${f}")
    ]))
  }
}

# Push image to ECR repository
resource "docker_registry_image" "this" {
  name = docker_image.this.name

  depends_on = [
    aws_ecr_repository.this
  ]
}
