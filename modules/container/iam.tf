# IAM role for Bedrock AgentCore Runtime
# This role provides minimal permissions following the principle of least privilege

resource "aws_iam_role" "agentcore" {
  count = local.create_role ? 1 : 0
  name  = "AgentCoreRuntime-${var.agent_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock-agentcore.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

# Base permissions: CloudWatch Logs, Bedrock invocation, ECR access
resource "aws_iam_role_policy" "base_permissions" {
  count = local.create_role ? 1 : 0
  name  = "BasePermissions"
  role  = aws_iam_role.agentcore[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:${var.region}:${local.account_id}:log-group:/aws/bedrock-agentcore/*",
          "arn:aws:logs:${var.region}:${local.account_id}:log-group:/aws/vendedlogs/bedrock-agentcore/*"
        ]
      },
      {
        Sid    = "BedrockModelInvocation"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:${var.region}::foundation-model/*",
          "arn:aws:bedrock:*::foundation-model/*",
          "arn:aws:bedrock:${var.region}:${local.account_id}:inference-profile/*"
        ]
      },
      {
        Sid    = "ECRImageAccess"
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = aws_ecr_repository.this.arn
      },
      {
        Sid    = "ECRTokenAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# AgentCore Memory permissions (conditional)
resource "aws_iam_role_policy" "memory" {
  count = local.create_role && var.enable_memory ? 1 : 0
  name  = "MemoryPermissions"
  role  = aws_iam_role.agentcore[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AgentCoreMemory"
        Effect = "Allow"
        Action = [
          "bedrock-agentcore:CreateMemory",
          "bedrock-agentcore:DeleteMemory",
          "bedrock-agentcore:GetMemory",
          "bedrock-agentcore:ListMemories",
          "bedrock-agentcore:UpdateMemory",
          "bedrock-agentcore:CreateSession",
          "bedrock-agentcore:DeleteSession",
          "bedrock-agentcore:GetSession",
          "bedrock-agentcore:ListSessions",
          "bedrock-agentcore:CreateEvent",
          "bedrock-agentcore:GetEvent",
          "bedrock-agentcore:ListEvents",
          "bedrock-agentcore:DeleteEvent",
          "bedrock-agentcore:CreateMemoryRecord",
          "bedrock-agentcore:GetMemoryRecord",
          "bedrock-agentcore:ListMemoryRecords",
          "bedrock-agentcore:DeleteMemoryRecord",
          "bedrock-agentcore:RetrieveMemoryRecords"
        ]
        Resource = "arn:aws:bedrock-agentcore:${var.region}:${local.account_id}:memory/*"
      }
    ]
  })
}

# Secrets Manager policy - only created if secrets are configured
resource "aws_iam_role_policy" "secrets_manager" {
  count = local.create_role && length(var.secrets_names) > 0 ? 1 : 0
  name  = "SecretsManagerPermissions"
  role  = aws_iam_role.agentcore[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SecretsAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = local.secret_arns
      }
    ]
  })
}

# S3 policy for outputs bucket access - allows agent to write research outputs
resource "aws_iam_role_policy" "s3_outputs" {
  count = local.create_role && var.create_outputs_bucket ? 1 : 0
  name  = "S3OutputsPermissions"
  role  = aws_iam_role.agentcore[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "OutputsBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${local.outputs_bucket_arn}/*"
      },
      {
        Sid    = "OutputsBucketList"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = local.outputs_bucket_arn
      }
    ]
  })
}
