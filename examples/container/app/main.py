"""Simple Strands Agent for AgentCore Runtime."""

from bedrock_agentcore.runtime import BedrockAgentCoreApp
from strands import Agent
from strands.models.bedrock import BedrockModel

app = BedrockAgentCoreApp()


@app.entrypoint
def invoke(payload: dict, context=None) -> dict:
    """
    Simple agent entrypoint using Strands Agent.

    Args:
        payload: Input data with 'prompt' key
        context: AgentCore runtime context (optional)

    Returns:
        Response dictionary with agent result
    """
    session_id = context.session_id if context else "unknown"

    print(f"Session ID: {session_id}")
    print(f"Received payload: {payload}")

    # Create a Bedrock model
    model = BedrockModel(model_id="us.anthropic.claude-3-5-sonnet-20241022-v2:0")

    # Create a simple Strands agent
    agent = Agent(
        name="SimpleAgent",
        system_prompt="You are a helpful assistant. Provide clear and concise responses.",
        model=model,
    )

    # Get the prompt from payload
    prompt = payload.get("prompt", "Hello!")

    # Run the agent
    result = agent(prompt)

    return {
        "status": "success",
        "prompt": prompt,
        "response": result,
        "session_id": session_id,
    }


if __name__ == "__main__":
    app.run()
