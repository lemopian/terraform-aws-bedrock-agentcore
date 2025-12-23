"""Test script to invoke the deployed AgentCore runtime."""

import json
import sys

import boto3


def invoke_runtime(runtime_id: str, prompt: str, region: str = "us-west-2"):
    """
    Invoke the AgentCore runtime with a prompt.

    Args:
        runtime_id: The runtime ID from Terraform output
        prompt: The prompt to send to the agent
        region: AWS region
    """
    client = boto3.client("bedrock-agentcore", region_name=region)

    payload = {"prompt": prompt}

    print(f"Invoking runtime: {runtime_id}")
    print(f"Payload: {json.dumps(payload, indent=2)}")
    print("-" * 60)

    response = client.invoke_agent_runtime(agentRuntimeId=runtime_id, body=json.dumps(payload))

    # Read the streaming response
    print("Response:")
    for event in response.get("body", []):
        if "chunk" in event:
            chunk_data = json.loads(event["chunk"]["bytes"])
            print(json.dumps(chunk_data, indent=2))

    return response


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python test_invoke.py <runtime_id> [prompt]")
        print("\nExample: python test_invoke.py example_agent-mP4koo2ihJ 'What is 2+2?'")
        sys.exit(1)

    runtime_id = sys.argv[1]
    prompt = (
        sys.argv[2]
        if len(sys.argv) > 2
        else "Hello! Tell me a short joke about Python programming."
    )

    try:
        invoke_runtime(runtime_id, prompt)
    except Exception as e:
        print(f"Error invoking runtime: {e}")
        import traceback

        traceback.print_exc()
        sys.exit(1)
