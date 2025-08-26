#!/bin/bash

# Build and load Docker images into Kind cluster
set -e

echo "🏗️  Building Docker images for Kubernetes deployment..."

# Navigate to sample app directory
cd "$(dirname "$0")/../sample-app"

# Build images
echo "📦 Building frontend image..."
docker build -t frontend:latest frontend/

echo "📦 Building api-gateway image..."
docker build -t api-gateway:latest api-gateway/

echo "📦 Building user-service image..."
docker build -t user-service:latest user-service/

echo "📦 Building product-service image..."
docker build -t product-service:latest product-service/

# Load images into Kind cluster
echo "🚀 Loading images into Kind cluster..."
kind load docker-image frontend:latest --name k8s-tutorial
kind load docker-image api-gateway:latest --name k8s-tutorial
kind load docker-image user-service:latest --name k8s-tutorial
kind load docker-image product-service:latest --name k8s-tutorial

echo "✅ All images built and loaded into Kind cluster!"
echo ""
echo "Next steps:"
echo "1. cd ../03-k8s-manifests"
echo "2. kubectl apply -f ."
