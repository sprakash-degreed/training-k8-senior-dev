#!/bin/bash

# Helm Chart Creation Script
# This script helps create Helm chart templates from existing Kubernetes manifests

set -e

echo "🚀 Creating Helm Chart from Scratch"
echo "====================================="

# Check if we're in the right directory
if [ ! -d "../../03-k8s-manifests" ]; then
    echo "❌ Error: Please run this script from 05-helm-from-scratch directory"
    echo "Expected directory structure: 05-helm-from-scratch/scripts/"
    exit 1
fi

# Create the chart
echo "📦 Creating new Helm chart..."
helm create my-microservices-chart

cd my-microservices-chart

# Clean up generated files
echo "🧹 Cleaning up generated files..."
rm -rf templates/tests/
rm templates/deployment.yaml
rm templates/service.yaml
rm templates/ingress.yaml
rm templates/hpa.yaml
rm templates/serviceaccount.yaml

echo "✅ Removed default template files"

# Copy reference manifests
echo "📋 Copying reference manifests..."
cp ../../03-k8s-manifests/*.yaml ./

echo "✅ Reference manifests copied"

# Create templates directory structure
echo "📁 Setting up template structure..."
echo "Templates directory is ready for conversion"

echo ""
echo "🎯 Next Steps:"
echo "1. Edit values.yaml with your configuration"
echo "2. Convert YAML manifests to template files"
echo "3. Test with: helm template my-app ."
echo "4. Install with: helm install my-app . --namespace microservices-app --create-namespace"
echo ""
echo "📚 Follow the helm-from-scratch-workshop.md guide for detailed instructions"
