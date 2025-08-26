#!/bin/bash

# Deploy application to Kubernetes
set -e

echo "🚀 Deploying application to Kubernetes..."

# Navigate to manifests directory
cd "$(dirname "$0")/../03-k8s-manifests"

# Apply manifests in order
echo "📋 Applying Kubernetes manifests..."

kubectl apply -f 00-namespace.yaml
echo "✅ Namespace created"

kubectl apply -f 01-mongodb.yaml
kubectl apply -f 02-postgres.yaml
kubectl apply -f 03-redis.yaml
echo "✅ Databases deployed"

# Wait for databases to be ready
echo "⏳ Waiting for databases to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/mongodb -n microservices-app
kubectl wait --for=condition=available --timeout=300s deployment/postgres -n microservices-app
kubectl wait --for=condition=available --timeout=300s deployment/redis -n microservices-app

kubectl apply -f 04-user-service.yaml
kubectl apply -f 05-product-service.yaml
echo "✅ Backend services deployed"

# Wait for backend services to be ready
echo "⏳ Waiting for backend services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/user-service -n microservices-app
kubectl wait --for=condition=available --timeout=300s deployment/product-service -n microservices-app

kubectl apply -f 06-api-gateway.yaml
kubectl apply -f 07-frontend.yaml
echo "✅ Frontend services deployed"

# Wait for frontend services to be ready
echo "⏳ Waiting for frontend services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/api-gateway -n microservices-app
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n microservices-app

kubectl apply -f 08-ingress.yaml
echo "✅ Ingress configured"

echo ""
echo "🎉 Application deployed successfully!"
echo ""
echo "📊 Deployment status:"
kubectl get pods -n microservices-app

echo ""
echo "🌐 Services:"
kubectl get services -n microservices-app

echo ""
echo "🔗 Access the application:"
echo "   Add to /etc/hosts: 127.0.0.1 k8s-tutorial.local"
echo "   Then visit: http://k8s-tutorial.local"
