# Kubernetes for Senior Developers: Hands-on Workshop Guide

## 🎯 Workshop Overview

**Duration**: 3 hours  
**Format**: Hands-on terminal sessions  
**Prerequisites**: Docker Desktop, kubectl, kind, helm installed  

---

## 📋 Pre-Workshop Setup (5 minutes)

### Verify Required Tools
```bash
# Check if all tools are installed
docker --version
kubectl version --client
kind version
helm version
```

### Clone the Repository
```bash
# Navigate to your repos directory
cd ~/repos

# If the repo doesn't exist, participants can create it step by step
# OR clone from your shared repository
```

---

## 🏗️ Part 1: Foundation & Docker Compose (30 minutes)

### Step 1: Understanding the Sample Application (5 minutes)

Let's examine our microservices architecture:

```bash
cd ~/repos/k8s-senior-dev-tutorial
tree sample-app/
```

**Architecture Overview:**
- **Frontend**: React app served by Node.js (port 3000)
- **API Gateway**: Express.js proxy (port 8080)  
- **User Service**: Node.js + MongoDB (port 3001)
- **Product Service**: Python Flask + PostgreSQL (port 5001)
- **Databases**: MongoDB, PostgreSQL, Redis

### Step 2: Start with Docker Compose (15 minutes)

First, let's see how this works with Docker Compose:

```bash
cd 01-docker-compose

# View the compose file
cat docker-compose.yml

# Build and start all services
docker-compose up --build -d

# Check status
docker-compose ps
```

### Step 3: Test the Application (10 minutes)

```bash
# Test individual services
curl http://localhost:3000/api/health
curl http://localhost:8080/api/gateway/health  
curl http://localhost:3001/health
curl http://localhost:5001/health

# Test API functionality
curl http://localhost:8080/api/products/products
curl http://localhost:8080/api/users/users

# Open in browser
open http://localhost:3000
```

**🔍 Discussion Points:**
- Service discovery via DNS names
- Environment variable configuration
- Volume persistence
- Network isolation

---

## 🚀 Part 2: Kubernetes Setup (20 minutes)

### Step 4: Clean Up Docker Compose (2 minutes)

```bash
cd ../01-docker-compose
docker-compose down
```

### Step 5: Create Kind Cluster (8 minutes)

```bash
cd ../02-kind-setup

# Examine the cluster configuration
cat kind-config.yaml

# Create the cluster
./setup-kind.sh
```

**Wait for completion, then verify:**
```bash
kubectl cluster-info
kubectl get nodes
```

### Step 6: Build and Load Images (10 minutes)

```bash
cd ../scripts

# Build all images and load into Kind cluster
./build-images.sh
```

**🔍 Discussion Points:**
- Multi-node cluster setup
- Ingress controller installation
- Image loading in Kind
- Kubernetes context switching

---

## 📋 Part 3: Kubernetes Manifests Deep Dive (45 minutes)

### Step 7: Examine Kubernetes Manifests (15 minutes)

```bash
cd ../03-k8s-manifests

# Look at each manifest file
ls -la

# Examine namespace creation
cat 00-namespace.yaml

# Look at database deployments
cat 01-mongodb.yaml
cat 02-postgres.yaml
cat 03-redis.yaml
```

**🔍 Key Concepts to Discuss:**
- **Namespace**: Logical cluster subdivision
- **Deployment**: Manages replica sets and pods
- **Service**: Network abstraction and service discovery
- **PersistentVolumeClaim**: Storage abstraction
- **Secret**: Sensitive data management

### Step 8: Deploy Step by Step (20 minutes)

Instead of using the script, let's deploy manually to understand each step:

```bash
# Create namespace first
kubectl apply -f 00-namespace.yaml
kubectl get namespaces

# Deploy databases
kubectl apply -f 01-mongodb.yaml
kubectl apply -f 02-postgres.yaml  
kubectl apply -f 03-redis.yaml

# Watch pods starting
kubectl get pods -n microservices-app -w
# Press Ctrl+C after all are running

# Check persistent volumes
kubectl get pv
kubectl get pvc -n microservices-app
```

Wait for databases to be ready, then continue:

```bash
# Deploy backend services
kubectl apply -f 04-user-service.yaml
kubectl apply -f 05-product-service.yaml

# Wait for backend services
kubectl get pods -n microservices-app

# Deploy frontend services
kubectl apply -f 06-api-gateway.yaml
kubectl apply -f 07-frontend.yaml

# Configure ingress
kubectl apply -f 08-ingress.yaml
```

### Step 9: Examine Running Application (10 minutes)

```bash
# Check everything is running
kubectl get all -n microservices-app

# Look at pod details
kubectl describe pod <any-pod-name> -n microservices-app

# Check logs
kubectl logs deployment/api-gateway -n microservices-app
```

**🔍 Discussion Points:**
- Pod lifecycle and status
- Resource requests and limits
- Health checks (liveness/readiness probes)
- Service endpoints

---

## 🧪 Part 4: Testing and Debugging (30 minutes)

### Step 10: Test with Port Forwarding (10 minutes)

```bash
# Test API Gateway
kubectl port-forward service/api-gateway 8080:8080 -n microservices-app &

# In another terminal (or after backgrounding)
curl http://localhost:8080/api/gateway/health
curl http://localhost:8080/api/products/products

# Stop port forwarding
pkill -f "port-forward.*api-gateway"
```

### Step 11: Database Connectivity (10 minutes)

```bash
# Connect to MongoDB
kubectl exec -it deployment/mongodb -n microservices-app -- mongo

# Inside MongoDB shell:
show dbs
use users
show collections
exit

# Connect to PostgreSQL
kubectl exec -it deployment/postgres -n microservices-app -- psql -U postgres -d products

# Inside PostgreSQL shell:
\dt
SELECT * FROM products;
\q

# Connect to Redis
kubectl exec -it deployment/redis -n microservices-app -- redis-cli
ping
exit
```

### Step 12: Scaling and Updates (10 minutes)

```bash
# Scale frontend
kubectl scale deployment frontend --replicas=4 -n microservices-app

# Watch scaling
kubectl get pods -n microservices-app -l app=frontend

# Update image (simulate)
kubectl set image deployment/frontend frontend=frontend:v2 -n microservices-app

# Check rollout status
kubectl rollout status deployment/frontend -n microservices-app

# Rollback if needed
kubectl rollout undo deployment/frontend -n microservices-app

# Check rollout history
kubectl rollout history deployment/frontend -n microservices-app
```

---

## 🛠️ Part 5: Operations and Troubleshooting (25 minutes)

### Step 13: Debugging Tools (15 minutes)

```bash
# Run the debug script to see comprehensive status
cd ../scripts
./debug.sh

# Practice common debugging commands
kubectl describe pod <pod-name> -n microservices-app
kubectl logs <pod-name> -n microservices-app
kubectl get events -n microservices-app --sort-by='.metadata.creationTimestamp'

# Check resource usage (if metrics server was installed)
kubectl top nodes
kubectl top pods -n microservices-app
```

### Step 14: Troubleshooting Exercise (10 minutes)

Let's break something and fix it:

```bash
# Introduce an error - scale to 0 replicas
kubectl scale deployment api-gateway --replicas=0 -n microservices-app

# Try to access the API
kubectl port-forward service/api-gateway 8080:8080 -n microservices-app &
curl http://localhost:8080/api/gateway/health

# Diagnose the issue
kubectl get pods -n microservices-app | grep api-gateway
kubectl get endpoints api-gateway -n microservices-app

# Fix the issue
kubectl scale deployment api-gateway --replicas=2 -n microservices-app

# Verify fix
kubectl get pods -n microservices-app | grep api-gateway
curl http://localhost:8080/api/gateway/health

# Clean up
pkill -f "port-forward"
```

---

## 📦 Part 6: Helm Introduction (25 minutes)

### Step 15: Examine Helm Chart Structure (10 minutes)

```bash
cd ../04-helm-charts/microservices-app

# Explore the chart structure
tree .

# Look at key files
cat Chart.yaml
cat values.yaml
cat templates/_helpers.tpl
```

### Step 16: Helm Template Generation (8 minutes)

```bash
# Generate templates without installing
helm template sample-app . --namespace microservices-app

# Generate specific template
helm template sample-app . --show-only templates/mongodb.yaml

# Validate the chart
helm lint .
```

### Step 17: Helm Deployment (7 minutes)

```bash
# First, clean up the existing deployment
kubectl delete namespace microservices-app

# Install with Helm
helm install sample-app . --namespace microservices-app --create-namespace

# Check the release
helm list -n microservices-app
helm status sample-app -n microservices-app

# Upgrade with new values
helm upgrade sample-app . --set replicaCount.frontend=3 -n microservices-app
```

---

## 🧹 Part 7: Cleanup and Wrap-up (15 minutes)

### Step 18: Resource Cleanup (5 minutes)

```bash
# Option 1: Helm uninstall
helm uninstall sample-app -n microservices-app

# Option 2: Manual cleanup
kubectl delete namespace microservices-app

# Clean up Kind cluster
kind delete cluster --name k8s-tutorial

# Clean up Docker images (optional)
docker system prune -f
```

### Step 19: Workshop Debrief (10 minutes)

**🔍 Key Learning Points Review:**

1. **Container Orchestration**: How K8s manages complex apps
2. **Declarative Configuration**: YAML manifests describe desired state
3. **Service Discovery**: How services find each other
4. **Scaling**: Horizontal pod autoscaling
5. **Storage**: Persistent volumes for stateful apps
6. **Networking**: Services, ingress, and load balancing
7. **Operations**: Debugging, logging, monitoring
8. **Package Management**: Helm for templating and releases

**🎯 Next Steps:**
- Explore advanced topics (operators, service mesh)
- Try with your own applications
- Learn about production considerations (RBAC, security)
- Consider CKA/CKAD certifications

---

## 📚 Quick Reference Commands

### Essential kubectl Commands
```bash
# Get resources
kubectl get pods,services,deployments -n microservices-app

# Describe resource
kubectl describe pod <pod-name> -n microservices-app

# Logs
kubectl logs -f deployment/frontend -n microservices-app

# Execute commands
kubectl exec -it <pod-name> -n microservices-app -- /bin/bash

# Port forwarding
kubectl port-forward service/frontend 3000:3000 -n microservices-app

# Scale
kubectl scale deployment frontend --replicas=3 -n microservices-app

# Rolling update
kubectl set image deployment/frontend frontend=frontend:v2 -n microservices-app

# Rollback
kubectl rollout undo deployment/frontend -n microservices-app
```

### Helm Commands
```bash
# Install
helm install release-name ./chart-name

# Upgrade
helm upgrade release-name ./chart-name

# List releases
helm list

# Uninstall
helm uninstall release-name

# Template validation
helm template release-name ./chart-name
```

---

## ⚠️ Troubleshooting Common Issues

### Pod Issues
```bash
# Pod stuck in Pending
kubectl describe pod <pod-name> -n microservices-app
# Look for: Insufficient resources, node selector issues

# Pod in CrashLoopBackOff
kubectl logs <pod-name> -n microservices-app
kubectl logs <pod-name> --previous -n microservices-app

# Image pull errors
kubectl describe pod <pod-name> -n microservices-app
# Check: Image name, image pull policy, registry access
```

### Service Issues
```bash
# Service not accessible
kubectl get endpoints <service-name> -n microservices-app
# Check if pods are selected properly

# DNS issues
kubectl run debug --image=busybox -it --rm --restart=Never -- nslookup <service-name>.microservices-app.svc.cluster.local
```

### Storage Issues
```bash
# PVC stuck in Pending
kubectl describe pvc <pvc-name> -n microservices-app
# Check: Storage class, available storage
```

---

**🎉 Congratulations! You've completed the Kubernetes hands-on workshop!**
