locals {
  account_id           = data.aws_caller_identity.current.account_id
  agent_name_sanitized = replace(var.agent_name, "-", "_")

  # ECR repository name: use provided or default to agent name
  ecr_repository_name = coalesce(var.ecr_repository_name, var.agent_name)

  # Dockerfile path: use provided or default to 'Dockerfile' in source path
  dockerfile_path = coalesce(var.dockerfile_path, "Dockerfile")

  # Determine if we need to create the role
  create_role = var.role_arn == null

  # IAM role ARN: use provided or created role
  role_arn = var.role_arn != null ? var.role_arn : aws_iam_role.agentcore[0].arn

  # Outputs bucket configuration
  create_outputs_bucket_resource = var.create_outputs_bucket && var.outputs_bucket_name == null

  outputs_bucket_name = var.create_outputs_bucket ? coalesce(
    var.outputs_bucket_name,
    "agentcore-outputs-${local.agent_name_sanitized}-${local.account_id}-${var.region}"
  ) : null

  # Outputs bucket ARN for IAM policies
  outputs_bucket_arn = var.create_outputs_bucket ? (
    var.outputs_bucket_name != null ? data.aws_s3_bucket.outputs_provided[0].arn : aws_s3_bucket.outputs[0].arn
  ) : null

  # Default tags
  default_tags = {
    ManagedBy = "terraform"
    Module    = "agentcore-container"
    Agent     = var.agent_name
  }

  tags = merge(local.default_tags, var.tags)

}
