# Minimal AgentCore Container Example

This is a minimal example of an AgentCore runtime deployed using Docker containers.

## Structure

- `main.py` - Simple agent entrypoint that echoes input
- `pyproject.toml` - Python dependencies (only bedrock-agentcore)
- `Dockerfile` - Container definition
- `.dockerignore` - Files to exclude from Docker build

## Usage

This app is deployed by the Terraform configuration in the parent directory. The module will:
1. Build the Docker image from the Dockerfile
2. Push to Amazon ECR
3. Deploy as an AgentCore runtime

## Testing Locally

```bash
# Install dependencies
uv pip install -e .

# Run locally (for development)
python main.py

# Or build and run with Docker
docker build -t agentcore-example .
docker run -p 8080:8080 agentcore-example
```

## Invoking the Runtime

After deployment, you can invoke the runtime using the AWS SDK or CLI with the runtime ARN from Terraform outputs.
