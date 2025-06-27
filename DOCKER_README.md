# Docker & Kubernetes Deployment Guide

This guide explains how to run the Snyk manager using Docker and Kubernetes.

## Prerequisites

- Docker installed
- Kubernetes cluster (for K8s deployment)
- kubectl configured (for K8s deployment)
- Snyk API token and Group ID

## Docker Deployment

### 1. Build and Run Locally

```bash
# Make the script executable
chmod +x docker-run.sh

# Option 1: Using .env file (for local development)
# Create a .env file with:
# SNYK_API_TOKEN=your-token-here
# SNYK_GROUP_ID=your-group-id-here
# SNYK_API_BASE_URL=https://app.eu.snyk.io
# SNYK_API_VERSION=v1
./docker-run.sh

# Option 2: Using environment variables
export SNYK_API_TOKEN=your-token-here
export SNYK_GROUP_ID=your-group-id-here
export SNYK_API_BASE_URL=https://app.eu.snyk.io
export SNYK_API_VERSION=v1
./docker-run.sh
```

### 2. Manual Docker Commands

```bash
# Build the image
docker build -t snyk-manager .

# Run with environment variables
docker run --rm -it \
  -e SNYK_API_TOKEN=your-token-here \
  -e SNYK_GROUP_ID=your-group-id-here \
  -e SNYK_API_BASE_URL=https://app.eu.snyk.io \
  -e SNYK_API_VERSION=v1 \
  snyk-manager

# Run with .env file (local development only)
docker run --rm -it --env-file .env snyk-manager

# Run with detached mode in Podman
podman run --rm -d --env-file .env --entrypoint="" snyk-manager sleep infinity
```

## Kubernetes Deployment

### 1. Create Secret and ConfigMap

```bash
# Create the secret with your API token
kubectl create secret generic snyk-credentials \
  --from-literal=SNYK_API_TOKEN=your-actual-token

# Create the configmap with non-sensitive configuration
kubectl create configmap snyk-config \
  --from-literal=SNYK_GROUP_ID=your-actual-group-id \
  --from-literal=SNYK_API_BASE_URL=https://app.eu.snyk.io \
  --from-literal=SNYK_API_VERSION=v1
```

### 2. Build and Load Image

```bash
# Build the Docker image
docker build -t snyk-manager:latest .

# For local Kubernetes (minikube, kind, etc.)
# Load the image into your cluster
# For minikube:
minikube image load snyk-manager:latest

# For kind:
kind load docker-image snyk-manager:latest
```

### 3. Deploy to Kubernetes

```bash
# Apply the secret
kubectl apply -f k8s/secret.yaml

# Apply the configmap
kubectl apply -f k8s/configmap.yaml

# Apply the deployment
kubectl apply -f k8s/deployment.yaml
```

### 4. Monitor and Check Logs

```bash
# Check deployment status
kubectl get deployments -n snyk-manager

# Get pods
kubectl get pods -n snyk-manager

# View logs
kubectl logs -n snyk-manager -l app=snyk-manager
```

### 5. Cleanup

```bash
# Remove deployment, secret, and configmap
kubectl delete deployment snyk-manager -n snyk-manager
kubectl delete secret snyk-credentials -n snyk-manager
kubectl delete configmap snyk-config -n snyk-manager
```

## Production Considerations

### For Production Kubernetes Deployment:

1. **Image Registry**: Push the Docker image to a container registry:
   ```bash
   docker tag snyk-manager:latest your-registry/snyk-manager:latest
   docker push your-registry/snyk-manager:latest
   ```

2. **Update image reference**: Use your registry URL instead of the local image name.

3. **Resource Limits**: Add resource requests and limits as needed:
   ```bash
   kubectl run snyk-manager --image=your-registry/snyk-manager:latest \
     --requests=cpu=100m,memory=128Mi \
     --limits=cpu=200m,memory=256Mi \
     --env="SNYK_API_TOKEN=..." \
     --env="SNYK_GROUP_ID=..." \
     --env="SNYK_API_BASE_URL=..." \
     --env="SNYK_API_VERSION=..."
   ```