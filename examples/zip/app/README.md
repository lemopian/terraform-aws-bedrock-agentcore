# Minimal AgentCore ZIP Example

This is a minimal example of an AgentCore runtime deployed using ZIP packaging.

## Structure

- `main.py` - Simple agent entrypoint that echoes input
- `pyproject.toml` - Python dependencies (only bedrock-agentcore)

## Usage

This app is deployed by the Terraform configuration in the parent directory. The module will:
1. Install dependencies using `uv`
2. Package the code into a ZIP file
3. Upload to S3
4. Deploy as an AgentCore runtime

## Testing Locally

```bash
# Install dependencies
uv pip install -e .

# Run locally (for development)
python main.py
```

## Invoking the Runtime

After deployment, you can invoke the runtime using the AWS SDK or CLI with the runtime ARN from Terraform outputs.
