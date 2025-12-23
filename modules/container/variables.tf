variable "agent_name" {
  type        = string
  description = "Name of the agent runtime (used for resource naming)"
}

variable "agent_description" {
  type        = string
  description = "Description of the agent"
  default     = "AgentCore Runtime"
}

variable "container_source_path" {
  type        = string
  description = "Path to the directory containing the Dockerfile and application code"
}

variable "dockerfile_path" {
  type        = string
  description = "Optional: Path to Dockerfile relative to container_source_path. If not provided, defaults to 'Dockerfile' in the source path."
  default     = null
}

variable "region" {
  type        = string
  description = "AWS region where the AgentCore runtime will be deployed"
}

variable "ecr_repository_name" {
  type        = string
  description = "Optional: ECR repository name. If not provided, defaults to agent_name."
  default     = null
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
  default     = "latest"
}

variable "role_arn" {
  type        = string
  description = "Optional: IAM role ARN for the agent runtime. If not provided, a minimal least-privilege role will be created."
  default     = null
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for the agent runtime"
  default     = {}
}

variable "enable_memory" {
  type        = bool
  description = "Whether to enable AgentCore memory for the agent"
  default     = false
}

variable "memory_event_expiry_duration" {
  type        = number
  description = "Event expiry duration for agent memory in days (must be between 7 and 365)"
  default     = 30
  validation {
    condition     = var.memory_event_expiry_duration >= 7 && var.memory_event_expiry_duration <= 365
    error_message = "memory_event_expiry_duration must be between 7 and 365 days."
  }
}

variable "network_mode" {
  type        = string
  description = "Network mode for the agent runtime"
  default     = "PUBLIC"
  validation {
    condition     = contains(["PUBLIC", "PRIVATE"], var.network_mode)
    error_message = "Network mode must be either PUBLIC or PRIVATE."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "secrets_names" {
  type        = map(string)
  description = "Map of environment variable names to Secrets Manager secret names. The runtime will fetch these secrets at startup."
  default     = {}
}

variable "create_outputs_bucket" {
  type        = bool
  description = "Whether to create an S3 bucket for agent outputs (research documents, findings, reports)"
  default     = false
}

variable "outputs_bucket_name" {
  type        = string
  description = "Optional: Custom S3 bucket name for agent outputs. If not provided, a unique bucket will be created."
  default     = null
}

variable "outputs_retention_days" {
  type        = number
  description = "Number of days to retain outputs in S3 (0 = never expire)"
  default     = 90
}

# Observability configuration (use secrets_names for API keys/tokens)

variable "idle_runtime_session_timeout" {
  type        = number
  description = "Idle runtime session timeout in seconds"
  default     = 60
}

variable "max_lifetime" {
  type        = number
  description = "Max lifetime in seconds"
  default     = 1000
}

variable "docker_platform" {
  type        = string
  description = "Docker platform for building images"
  default     = "linux/arm64" # currently only arm64 is supported
  validation {
    condition     = contains(["linux/arm64"], var.docker_platform)
    error_message = "Docker platform must be linux/arm64."
  }
}
