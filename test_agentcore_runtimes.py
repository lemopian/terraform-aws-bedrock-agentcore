"""Test AgentCore Runtimes with correct API."""

import argparse
import json
import os
from datetime import datetime

import boto3


def test_runtime(
    runtime_arn: str,
    runtime_name: str,
    test_prompt: str,
    region: str,
    profile_name: str | None = None,
) -> dict | None:
    """
    Test an AgentCore runtime with the correct API.

    Args:
        runtime_arn: Full ARN of the runtime
        runtime_name: Friendly name for display
        test_prompt: The prompt to send
        region: AWS region
        profile_name: AWS profile name (optional)

    Returns:
        Response data from the runtime, or None if failed
    """
    print(f"\n{'='*70}")
    print(f"Testing: {runtime_name}")
    print(f"ARN: {runtime_arn}")
    print(f"Prompt: {test_prompt}")
    print(f"{'='*70}\n")

    try:
        session_kwargs = {"region_name": region}
        if profile_name:
            session_kwargs["profile_name"] = profile_name

        session = boto3.Session(**session_kwargs)
        client = session.client("bedrock-agentcore")

        payload = json.dumps({"prompt": test_prompt})
        session_id = f"test-session-{datetime.now().strftime('%Y%m%d%H%M%S')}-{runtime_name}"

        print(f"Session ID: {session_id}")
        print("Invoking runtime...\n")

        response = client.invoke_agent_runtime(
            agentRuntimeArn=runtime_arn,
            runtimeSessionId=session_id,
            payload=payload,
            qualifier="DEFAULT",
        )

        response_body = response["response"].read()
        response_data = json.loads(response_body)

        print("✅ SUCCESS!")
        print("\nAgent Response:")
        print(json.dumps(response_data, indent=2))
        print(f"\n{'='*70}\n")

        return response_data

    except Exception as e:
        print(f"❌ ERROR: {type(e).__name__}: {e}")
        import traceback

        traceback.print_exc()
        print(f"\n{'='*70}\n")
        return None


def main() -> None:
    """Test AgentCore runtimes from command line arguments or environment."""

    parser = argparse.ArgumentParser(
        description="Test AWS Bedrock AgentCore Runtimes",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Test a single runtime
  python test_agentcore_runtimes.py --runtime-arn arn:aws:bedrock-agentcore:us-west-2:123456789012:runtime/my-agent-abc123

  # Test with custom prompt and profile
  python test_agentcore_runtimes.py --runtime-arn arn:aws:... --prompt "What is 2+2?" --profile my-profile

  # Test multiple runtimes
  python test_agentcore_runtimes.py --runtime-arn arn:aws:...1 --runtime-arn arn:aws:...2
        """,
    )

    parser.add_argument(
        "--runtime-arn",
        action="append",
        required=True,
        help="ARN of the runtime to test (can be specified multiple times)",
    )
    parser.add_argument(
        "--prompt",
        default="Hello, what can you help me with?",
        help="Prompt to send to the runtime (default: 'Hello, what can you help me with?')",
    )
    parser.add_argument(
        "--region",
        default=os.environ.get("AWS_REGION", "us-west-2"),
        help="AWS region (default: AWS_REGION env var or us-west-2)",
    )
    parser.add_argument(
        "--profile",
        default=os.environ.get("AWS_PROFILE"),
        help="AWS profile name (default: AWS_PROFILE env var or default profile)",
    )

    args = parser.parse_args()

    print("\n" + "=" * 70)
    print("AWS Bedrock AgentCore Runtime Testing")
    print("=" * 70)
    print(f"Region: {args.region}")
    print(f"Profile: {args.profile or 'default'}")
    print(f"Runtimes to test: {len(args.runtime_arn)}")
    print("=" * 70)

    for idx, runtime_arn in enumerate(args.runtime_arn, 1):
        runtime_name = f"Runtime-{idx}"
        print(f"\n🔹 TEST {idx}: {runtime_name}")

        test_runtime(
            runtime_arn=runtime_arn,
            runtime_name=runtime_name,
            test_prompt=args.prompt,
            region=args.region,
            profile_name=args.profile,
        )

    print("\n" + "=" * 70)
    print("🎉 Testing Complete!")
    print("=" * 70 + "\n")


if __name__ == "__main__":
    main()
