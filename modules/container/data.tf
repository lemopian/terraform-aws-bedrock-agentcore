# Get current AWS account ID and region
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Validate user-provided IAM role exists (only if role_arn is provided)
data "aws_iam_role" "provided" {
  count = var.role_arn != null ? 1 : 0
  name  = element(split("/", var.role_arn), length(split("/", var.role_arn)) - 1)
}


# Data source for existing outputs bucket (if provided)
data "aws_s3_bucket" "outputs_provided" {
  count  = var.create_outputs_bucket && var.outputs_bucket_name != null ? 1 : 0
  bucket = var.outputs_bucket_name
}
