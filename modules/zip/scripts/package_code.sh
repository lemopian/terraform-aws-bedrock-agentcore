#!/bin/bash
# Package Python code and dependencies into a ZIP file for AgentCore runtime
# This script is called by Terraform to create the deployment package

set -e

# Validate required environment variables
if [ -z "$SOURCE_PATH" ] || [ -z "$OUTPUT_DIR" ] || [ -z "$ENTRY_FILE" ]; then
  echo "Error: Required environment variables not set"
  echo "Required: SOURCE_PATH, OUTPUT_DIR, ENTRY_FILE"
  echo "Optional: ADDITIONAL_DIRS"
  exit 1
fi

# Convert paths to absolute
if [ ! -d "$SOURCE_PATH" ]; then
  echo "Error: Source path does not exist: $SOURCE_PATH"
  exit 1
fi
SOURCE_PATH=$(cd "$SOURCE_PATH" && pwd)
OUTPUT_DIR=$(cd "$OUTPUT_DIR" && pwd)
DEPS_DIR="$OUTPUT_DIR/dependencies"
ZIP_PATH="$OUTPUT_DIR/deployment_package.zip"

echo "=== Step 2: Packaging Code ==="
echo "Source: $SOURCE_PATH"
echo "Dependencies Dir: $DEPS_DIR"
echo "Zip Path: $ZIP_PATH"
echo "Entry File: $ENTRY_FILE"
echo "Additional Dirs: $ADDITIONAL_DIRS"

# Validate dependencies directory exists
if [ ! -d "$DEPS_DIR" ]; then
  echo "Error: Dependencies directory not found: $DEPS_DIR"
  echo "Run install_dependencies.sh first"
  exit 1
fi

# Remove old zip
rm -f "$ZIP_PATH"

# Create zip from cached dependencies
echo "Creating deployment package from cached dependencies..."
cd "$DEPS_DIR"
zip -rq "$ZIP_PATH" .

# Add entry file
echo "Adding entry file: $ENTRY_FILE"
cd "$SOURCE_PATH"
if [ ! -f "$ENTRY_FILE" ]; then
  echo "Error: Entry file not found: $SOURCE_PATH/$ENTRY_FILE"
  exit 1
fi
zip -q "$ZIP_PATH" "$ENTRY_FILE"

# Add additional source directories (including .env files)
if [ -n "$ADDITIONAL_DIRS" ]; then
  for dir in $ADDITIONAL_DIRS; do
    if [ -d "$SOURCE_PATH/$dir" ]; then
      echo "Adding directory: $dir"
      cd "$SOURCE_PATH"
      # Include all files including hidden ones like .env
      zip -rq "$ZIP_PATH" "$dir" -x "*.pyc" -x "*__pycache__*"
    else
      echo "Warning: Directory $dir not found, skipping..."
    fi
  done
fi

echo "=== Packaging Complete ==="
echo "Package created: $ZIP_PATH"
ls -lh "$ZIP_PATH"
