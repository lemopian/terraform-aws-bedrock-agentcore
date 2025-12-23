# Agent Runtime
resource "aws_bedrockagentcore_agent_runtime" "this" {
  agent_runtime_name = local.agent_name_sanitized
  description        = var.agent_description
  role_arn           = local.role_arn

  agent_runtime_artifact {
    container_configuration {
      container_uri = "${replace(data.aws_ecr_authorization_token.token.proxy_endpoint, "https://", "")}/${local.ecr_repository_name}:${var.image_tag}"
    }
  }

  lifecycle_configuration {
    idle_runtime_session_timeout = var.idle_runtime_session_timeout
    max_lifetime                 = var.max_lifetime
  }

  network_configuration {
    network_mode = var.network_mode
  }

  environment_variables = merge(
    var.environment_variables,
    {
      AWS_REGION = var.region,
      # CONTAINER_HASH forces new agent version creation when code/image changes.
      # AgentCore only creates new versions when configuration changes, so we inject
      # a hash of all source files as an env var to trigger version updates on code changes.
      CONTAINER_HASH = local.container_hash,
    },
    var.enable_memory ? {
      ENABLE_MEMORY       = "true",
      AGENTCORE_MEMORY_ID = aws_bedrockagentcore_memory.this[0].id,
    } : {},
    length(var.secrets_names) > 0 ? {
      SECRETS_CONFIG = local.secrets_config
    } : {},
  )

  tags = local.tags

  depends_on = [docker_registry_image.this]
}

# Agent Memory (conditional)
resource "aws_bedrockagentcore_memory" "this" {
  count = var.enable_memory ? 1 : 0

  name                  = local.agent_name_sanitized
  description           = "${var.agent_description} Memory"
  event_expiry_duration = var.memory_event_expiry_duration

  tags = local.tags
}
