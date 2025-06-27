#!/bin/bash

# Detect architecture
ARCH=$(uname -m)
DOCKERFILE="Dockerfile.linux-x64"  # Default to x64

if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
    DOCKERFILE="Dockerfile.linux-arm64"
fi

# Build the Docker image
echo "Building Docker image for architecture: $ARCH using $DOCKERFILE..."
docker build -t snyk-manager -f $DOCKERFILE .

# For local development - check if .env file exists and use it
if [ -f ".env" ]; then
    echo "Running locally with .env file..."
    docker run --rm -it --env-file .env snyk-manager "$@"
else
    echo "Running with environment variables (Kubernetes-compatible)..."
    docker run --rm -it \
        -e SNYK_API_TOKEN \
        -e SNYK_GROUP_ID \
        -e SNYK_API_BASE_URL \
        -e SNYK_API_VERSION \
        snyk-manager "$@"
fi