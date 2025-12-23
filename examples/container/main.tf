terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "agentcore_runtime" {
  source = "../../modules/container"

  agent_name            = var.agent_name
  region                = var.region
  container_source_path = "${path.module}/app"
}

output "agent_runtime_arn" {
  description = "ARN of the deployed agent runtime"
  value       = module.agentcore_runtime.agent_runtime_arn
}

output "agent_runtime_id" {
  description = "ID of the deployed agent runtime"
  value       = module.agentcore_runtime.agent_runtime_id
}

output "agent_runtime_name" {
  description = "Name of the deployed agent runtime"
  value       = module.agentcore_runtime.agent_runtime_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.agentcore_runtime.ecr_repository_url
}
