#!/bin/bash

# Essential kubectl commands for debugging and monitoring
set -e

NAMESPACE="microservices-app"

echo "🔍 Kubernetes Debugging and Monitoring Commands"
echo "=============================================="

echo ""
echo "📊 Current cluster status:"
kubectl cluster-info

echo ""
echo "🏷️  Nodes:"
kubectl get nodes -o wide

echo ""
echo "📋 Namespaces:"
kubectl get namespaces

echo ""
echo "🚀 Pods in $NAMESPACE:"
kubectl get pods -n $NAMESPACE -o wide

echo ""
echo "🌐 Services in $NAMESPACE:"
kubectl get services -n $NAMESPACE

echo ""
echo "💾 Persistent Volume Claims:"
kubectl get pvc -n $NAMESPACE

echo ""
echo "🔗 Ingress:"
kubectl get ingress -n $NAMESPACE

echo ""
echo "📈 Resource usage:"
kubectl top nodes 2>/dev/null || echo "Metrics server not available"
kubectl top pods -n $NAMESPACE 2>/dev/null || echo "Metrics server not available"

echo ""
echo "🔧 Useful debugging commands:"
echo "================================"
echo ""
echo "# Check pod logs:"
echo "kubectl logs -f deployment/frontend -n $NAMESPACE"
echo "kubectl logs -f deployment/api-gateway -n $NAMESPACE"
echo "kubectl logs -f deployment/user-service -n $NAMESPACE"
echo "kubectl logs -f deployment/product-service -n $NAMESPACE"
echo ""
echo "# Describe resources:"
echo "kubectl describe pod <pod-name> -n $NAMESPACE"
echo "kubectl describe service <service-name> -n $NAMESPACE"
echo ""
echo "# Execute commands in pods:"
echo "kubectl exec -it deployment/mongodb -n $NAMESPACE -- mongo"
echo "kubectl exec -it deployment/postgres -n $NAMESPACE -- psql -U postgres -d products"
echo "kubectl exec -it deployment/redis -n $NAMESPACE -- redis-cli"
echo ""
echo "# Port forwarding for local testing:"
echo "kubectl port-forward service/frontend 3000:3000 -n $NAMESPACE"
echo "kubectl port-forward service/api-gateway 8080:8080 -n $NAMESPACE"
echo ""
echo "# Scale deployments:"
echo "kubectl scale deployment frontend --replicas=3 -n $NAMESPACE"
echo ""
echo "# Update deployments:"
echo "kubectl set image deployment/frontend frontend=frontend:v2 -n $NAMESPACE"
echo ""
echo "# Watch resources:"
echo "kubectl get pods -n $NAMESPACE -w"
