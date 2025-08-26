#!/bin/bash

# Setup Kind cluster for Kubernetes tutorial
set -e

echo "🚀 Setting up Kind cluster for Kubernetes tutorial..."

# Check if kind is installed
if ! command -v kind &> /dev/null; then
    echo "❌ Kind is not installed. Please install it first:"
    echo "   On macOS: brew install kind"
    echo "   On Linux: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first:"
    echo "   On macOS: brew install kubectl"
    echo "   On Linux: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/"
    exit 1
fi

# Delete existing cluster if it exists
if kind get clusters | grep -q "k8s-tutorial"; then
    echo "🗑️  Deleting existing k8s-tutorial cluster..."
    kind delete cluster --name k8s-tutorial
fi

# Create new cluster
echo "🏗️  Creating Kind cluster..."
kind create cluster --config kind-config.yaml

# Wait for cluster to be ready
echo "⏳ Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Install NGINX Ingress Controller
echo "🌐 Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
echo "⏳ Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# Verify cluster
echo "✅ Cluster setup complete!"
echo ""
echo "📊 Cluster information:"
kubectl cluster-info --context kind-k8s-tutorial

echo ""
echo "🏷️  Nodes:"
kubectl get nodes

echo ""
echo "🎉 Kind cluster is ready! You can now deploy applications to it."
echo ""
echo "Next steps:"
echo "1. cd ../03-k8s-manifests"
echo "2. kubectl apply -f ."
