# AWS Bedrock AgentCore Terraform Deployment

Terraform modules for deploying AWS Bedrock AgentCore runtimes with security-first, minimalist design.

## Overview

This repository provides two Terraform modules for deploying AgentCore runtimes:

- **`modules/zip`** - Deploy Python agents packaged as ZIP files
- **`modules/container`** - Deploy agents as Docker containers via ECR

Both modules follow the same design principles:

- **Security First**: Least-privilege IAM roles with conditional permissions
- **Minimalist**: All optional features disabled by default
- **Consistent**: Shared variable patterns and structure across both modules

## Quick Start

### ZIP Deployment

```hcl
module "agentcore_runtime" {
  source = "./modules/zip"

  agent_name          = "my-agent"
  region              = "us-west-2"
  runtime_source_path = "./app"
}
```

### Container Deployment

```hcl
module "agentcore_runtime" {
  source = "./modules/container"

  agent_name            = "my-agent"
  region                = "us-west-2"
  container_source_path = "./app"
}
```

## Module Features

### Base Features (Always Enabled)

- CloudWatch Logs (scoped to AgentCore paths)
- S3 deployment artifact access (ZIP) or ECR access (Container)
- Basic Bedrock foundation model invocation
- Automatic IAM role creation (or use custom role)

### Optional Features (Disabled by Default)

Enable features by setting variables:

```hcl
module "agentcore_runtime" {
  source = "./modules/zip"

  agent_name          = "my-agent"
  region              = "us-west-2"
  runtime_source_path = "./app"

  # Optional features
  enable_memory         = true  # AgentCore Memory
  create_outputs_bucket = true  # S3 bucket for agent outputs

  # Secure secrets configuration (for API keys, tokens, credentials)
  secrets_names = {
    "API_KEY"    = "my-app/api-key"
    "API_SECRET" = "my-app/api-secret"
  }

  # Non-sensitive configuration
  environment_variables = {
    API_ENDPOINT = "https://api.example.com"
    LOG_LEVEL    = "INFO"
  }
}
```

## Security Principles

### IAM Least Privilege

The modules create minimal IAM roles with:

- **Base permissions** always included (logs, deployment artifact, Bedrock)
- **Conditional permissions** added only when features are enabled
- **No wildcards** except where unavoidable (e.g., ECR token)
- **Scoped resources** to specific ARNs or patterns

### Environment Variable Security

**Safe for env vars** (non-sensitive):

- Feature flags: `ENABLE_MEMORY`, `AWS_REGION`
- Resource IDs: `AGENTCORE_MEMORY_ID`
- Public endpoints: API URLs, service endpoints
- Configuration: Log levels, timeouts, feature toggles
- Any non-secret configuration values

**Must use Secrets Manager** (sensitive):

- API keys, passwords, tokens, credentials
- Authentication tokens for external services
- Database passwords
- Any secret or sensitive data
- Use `secrets_names` variable to map env vars to secrets

**How Secrets Work:**

1. Store secrets in AWS Secrets Manager (JSON format if multiple keys)
2. Reference via `secrets_names` in Terraform
3. IAM policies automatically grant runtime access
4. Application retrieves at runtime using `SECRETS_CONFIG` env var

**Example:**

```hcl
# Store in Secrets Manager
# Secret name: "my-app/credentials"
# Secret value: {"API_KEY": "abc123", "API_SECRET": "xyz789"}

module "agentcore_runtime" {
  source = "./modules/zip"

  secrets_names = {
    "API_KEY"    = "my-app/credentials"
    "API_SECRET" = "my-app/credentials"
  }

  environment_variables = {
    API_ENDPOINT = "https://api.example.com"
    LOG_LEVEL    = "INFO"
  }
}
```

## Examples

See the `examples/` directory for complete working examples:

- **`examples/zip/`** - Minimal ZIP deployment example
- **`examples/container/`** - Minimal container deployment example

Each example includes:

- Terraform configuration calling the module
- Simple "hello world" agent application
- README with usage instructions

## Module Documentation

### Shared Variables

Variables available in both modules:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `agent_name` | string | *required* | Name of the agent runtime |
| `agent_description` | string | `"AgentCore Runtime"` | Description of the agent |
| `region` | string | *required* | AWS region for deployment |
| `role_arn` | string | `null` | Custom IAM role (creates minimal role if null) |
| `environment_variables` | map(string) | `{}` | Non-sensitive environment variables |
| `enable_memory` | bool | `false` | Enable AgentCore Memory |
| `memory_event_expiry_duration` | number | `30` | Memory event expiry in days (7-365) |
| `secrets_names` | map(string) | `{}` | Map of env vars to secret names |
| `create_outputs_bucket` | bool | `false` | Create S3 bucket for outputs |
| `outputs_bucket_name` | string | `null` | Custom outputs bucket name |
| `outputs_retention_days` | number | `90` | Outputs retention in days |
| `network_mode` | string | `"PUBLIC"` | Network mode (PUBLIC/PRIVATE) |
| `idle_runtime_session_timeout` | number | `60` | Idle timeout in seconds |
| `max_lifetime` | number | `1000` | Max lifetime in seconds |
| `tags` | map(string) | `{}` | Resource tags |

### ZIP Module Specific

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `runtime_source_path` | string | *required* | Path to Python code directory |
| `entry_file` | string | `"main.py"` | Entry point file name |
| `python_runtime` | string | `"PYTHON_3_13"` | Python runtime version |
| `bucket_name` | string | `null` | Custom S3 bucket for deployment |

### Container Module Specific

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `container_source_path` | string | *required* | Path to Dockerfile directory |
| `dockerfile_path` | string | `null` | Custom Dockerfile path |
| `ecr_repository_name` | string | `null` | Custom ECR repository name |
| `image_tag` | string | `"latest"` | Docker image tag |
| `docker_platform` | string | `"linux/arm64"` | Docker build platform |

## Project Structure

```
bedrock-agentcore-terraform-deployment/
├── modules/
│   ├── zip/                          # ZIP deployment module
│   │   ├── main.tf                   # AgentCore runtime resource
│   │   ├── variables.tf              # Input variables
│   │   ├── outputs.tf                # Module outputs
│   │   ├── locals.tf                 # Computed locals
│   │   ├── data.tf                   # Data sources
│   │   ├── iam.tf                    # IAM role and policies
│   │   ├── secrets.tf                # Secrets Manager integration
│   │   ├── providers.tf              # Provider requirements
│   │   ├── s3.tf                     # S3 buckets
│   │   ├── packaging.tf              # Build/package logic
│   │   └── scripts/                  # Bash scripts
│   │       ├── install_dependencies.sh
│   │       └── package_code.sh
│   │
│   └── container/                    # Container deployment module
│       ├── main.tf                   # AgentCore runtime resource
│       ├── variables.tf              # Input variables
│       ├── outputs.tf                # Module outputs
│       ├── locals.tf                 # Computed locals
│       ├── data.tf                   # Data sources
│       ├── iam.tf                    # IAM role and policies
│       ├── secrets.tf                # Secrets Manager integration
│       ├── providers.tf              # Provider requirements
│       ├── ecr.tf                    # ECR repository
│       ├── docker.tf                 # Docker build/push
│       └── s3.tf                     # S3 outputs bucket
│
└── examples/
    ├── zip/                          # ZIP deployment example
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── terraform.tfvars
    │   └── app/
    │       ├── pyproject.toml
    │       ├── main.py
    │       └── README.md
    │
    └── container/                    # Container deployment example
        ├── main.tf
        ├── variables.tf
        ├── terraform.tfvars
        └── app/
            ├── pyproject.toml
            ├── main.py
            ├── Dockerfile
            ├── .dockerignore
            └── README.md
```

## Requirements

### General

- Terraform >= 1.5.0
- AWS Provider >= 5.0
- AWS account with appropriate permissions

### ZIP Module

- `uv` package manager installed locally
- Python 3.11+ for local development

### Container Module

- Docker installed locally
- Docker provider >= 3.0

## License

See LICENSE file for details.
