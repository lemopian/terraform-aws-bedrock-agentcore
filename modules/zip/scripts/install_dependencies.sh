#!/bin/bash
# Install Python dependencies using uv for AgentCore runtime
# This script is called by Terraform to package dependencies

set -e

# Validate required environment variables
if [ -z "$SOURCE_PATH" ] || [ -z "$OUTPUT_DIR" ] || [ -z "$PYTHON_VERSION" ]; then
  echo "Error: Required environment variables not set"
  echo "Required: SOURCE_PATH, OUTPUT_DIR, PYTHON_VERSION"
  exit 1
fi

# Convert source path to absolute
if [ ! -d "$SOURCE_PATH" ]; then
  echo "Error: Source path does not exist: $SOURCE_PATH"
  exit 1
fi
SOURCE_PATH=$(cd "$SOURCE_PATH" && pwd)

# Create and convert output directory to absolute path
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR=$(cd "$OUTPUT_DIR" && pwd)
DEPS_DIR="$OUTPUT_DIR/dependencies"

echo "=== Step 1: Installing Dependencies ==="
echo "Source: $SOURCE_PATH"
echo "Dependencies Dir: $DEPS_DIR"
echo "Python Version: $PYTHON_VERSION"

# Validate pyproject.toml exists
if [ ! -f "$SOURCE_PATH/pyproject.toml" ]; then
  echo "Error: pyproject.toml not found in $SOURCE_PATH"
  exit 1
fi

# Clean up existing dependencies
rm -rf "$DEPS_DIR"
mkdir -p "$DEPS_DIR"

# Install dependencies using uv
echo "Installing dependencies from pyproject.toml..."

# Try to find uv in common locations
UV_CMD="uv"
if [ ! -x "$(command -v $UV_CMD)" ]; then
  if [ -x "$HOME/.local/bin/uv" ]; then
    UV_CMD="$HOME/.local/bin/uv"
  elif [ -x "/usr/local/bin/uv" ]; then
    UV_CMD="/usr/local/bin/uv"
  elif [ -x "/opt/homebrew/bin/uv" ]; then
    UV_CMD="/opt/homebrew/bin/uv"
  else
    echo "Error: uv not found. Please install with: pip install uv"
    exit 1
  fi
fi

$UV_CMD pip install \
  --python-platform aarch64-manylinux2014 \
  --python-version "$PYTHON_VERSION" \
  --target="$DEPS_DIR" \
  --only-binary=:all: \
  -r "$SOURCE_PATH/pyproject.toml"

echo "=== Dependencies Installation Complete ==="
echo "Dependencies installed to: $DEPS_DIR"
