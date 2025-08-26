#!/bin/bash

# Helm Template Validator Script
# Validates and tests Helm chart templates

set -e

CHART_DIR="my-microservices-chart"

echo "🔍 Helm Chart Validation Script"
echo "==============================="

# Check if chart directory exists
if [ ! -d "$CHART_DIR" ]; then
    echo "❌ Error: Chart directory '$CHART_DIR' not found"
    echo "Run create-chart.sh first to create the chart"
    exit 1
fi

cd "$CHART_DIR"

echo "1. 🧪 Linting the chart..."
helm lint .

echo ""
echo "2. 📋 Generating template preview..."
helm template my-app . --namespace microservices-app

echo ""
echo "3. 🔧 Testing with custom values..."
helm template my-app . --set mongodb.replicaCount=2 --set userService.replicaCount=3

echo ""
echo "4. 🎯 Validating against Kubernetes API..."
helm template my-app . | kubectl apply --dry-run=client -f -

echo ""
echo "5. 📦 Testing packaging..."
cd ..
helm package "$CHART_DIR"

echo ""
echo "✅ Chart validation completed successfully!"
echo ""
echo "📚 Generated files:"
ls -la *.tgz 2>/dev/null || echo "No packages found"

echo ""
echo "🚀 Ready to install with:"
echo "helm install my-microservices-app ./$CHART_DIR --namespace microservices-app --create-namespace"
