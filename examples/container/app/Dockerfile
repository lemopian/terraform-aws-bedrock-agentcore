FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim

WORKDIR /app

# Environment variables
ENV UV_SYSTEM_PYTHON=1 \
    UV_COMPILE_BYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Copy dependency files first for better layer caching
COPY pyproject.toml .

# Install dependencies as root (required for system Python)
RUN uv pip install --no-cache .

# Create non-root user after installation
RUN useradd -m -u 1000 -s /bin/bash agentcore && \
    chown -R agentcore:agentcore /app

# Switch to non-root user
USER agentcore

# Copy all application code after dependencies (with correct ownership)
COPY --chown=agentcore:agentcore . .


EXPOSE 8080

# Use exec form for better signal handling
CMD ["python", "-u", "main.py"]
