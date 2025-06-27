#!/bin/bash

# Detect architecture
ARCH=$(uname -m)
DOCKERFILE="Dockerfile.linux-x64"  # Default to x64

if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
    DOCKERFILE="Dockerfile.linux-arm64"
fi

# Build the Podman image
echo "Building Podman image for architecture: $ARCH using $DOCKERFILE..."
podman build -t snyk-manager -f $DOCKERFILE .

# For local development - check if .env file exists and use it
if [ -f ".env" ]; then
    echo "Running locally with .env file..."
    podman run --rm -it --env-file .env snyk-manager "$@"
else
    echo "Running with environment variables (Kubernetes-compatible)..."
    podman run --rm -it \
        -e SNYK_API_TOKEN \
        -e SNYK_GROUP_ID \
        -e SNYK_API_BASE_URL \
        -e SNYK_API_VERSION \
        snyk-manager "$@"
fi