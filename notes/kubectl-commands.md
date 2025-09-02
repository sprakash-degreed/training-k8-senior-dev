# Common kubectl Commands for Kubernetes Tutorial

## Resource Management

### Get Resources
```bash
# List all resources in a namespace
kubectl get all -n microservices-app

# Get specific resource types
kubectl get pods,services,deployments -n microservices-app

# Get resources with more details
kubectl get pods -o wide -n microservices-app

# Get resources in YAML format
kubectl get deployment frontend -o yaml -n microservices-app

# Watch resources for changes
kubectl get pods -w -n microservices-app
```

### Describe Resources
```bash
# Describe a pod
kubectl describe pod <pod-name> -n microservices-app

# Describe a deployment
kubectl describe deployment frontend -n microservices-app

# Describe a service
kubectl describe service api-gateway -n microservices-app

# Describe a node
kubectl describe node <node-name>
```

## Logs and Debugging

### View Logs
```bash
# Get logs from a deployment
kubectl logs deployment/frontend -n microservices-app

# Follow logs in real-time
kubectl logs -f deployment/api-gateway -n microservices-app

# Get logs from a specific pod
kubectl logs <pod-name> -n microservices-app

# Get logs from previous container instance
kubectl logs <pod-name> --previous -n microservices-app

# Get logs from all containers in a pod
kubectl logs <pod-name> --all-containers -n microservices-app
```

### Execute Commands in Pods
```bash
# Execute a command in a pod
kubectl exec -it deployment/mongodb -n microservices-app -- mongo

# Connect to PostgreSQL
kubectl exec -it deployment/postgres -n microservices-app -- psql -U postgres -d products

# Connect to Redis
kubectl exec -it deployment/redis -n microservices-app -- redis-cli

# Get a shell in a pod
kubectl exec -it <pod-name> -n microservices-app -- /bin/bash
```

## Port Forwarding

```bash
# Forward local port to a service
kubectl port-forward service/frontend 3000:3000 -n microservices-app

# Forward local port to a pod
kubectl port-forward pod/<pod-name> 8080:8080 -n microservices-app

# Forward to a deployment
kubectl port-forward deployment/api-gateway 8080:8080 -n microservices-app
```

## Scaling and Updates

### Scaling
```bash
# Scale a deployment
kubectl scale deployment frontend --replicas=3 -n microservices-app

# Scale multiple deployments
kubectl scale deployment frontend api-gateway --replicas=2 -n microservices-app

# Auto-scale based on CPU usage
kubectl autoscale deployment frontend --cpu-percent=70 --min=2 --max=10 -n microservices-app
```

### Rolling Updates
```bash
# Update image
kubectl set image deployment/frontend frontend=frontend:v2 -n microservices-app

# Check rollout status
kubectl rollout status deployment/frontend -n microservices-app

# View rollout history
kubectl rollout history deployment/frontend -n microservices-app

# Rollback to previous version
kubectl rollout undo deployment/frontend -n microservices-app

# Rollback to specific revision
kubectl rollout undo deployment/frontend --to-revision=2 -n microservices-app
```

## Configuration Management

### ConfigMaps
```bash
# Create ConfigMap from literal values
kubectl create configmap app-config --from-literal=api_url=http://api.example.com -n microservices-app

# Create ConfigMap from file
kubectl create configmap app-config --from-file=config.yaml -n microservices-app

# View ConfigMap
kubectl get configmap app-config -o yaml -n microservices-app
```

### Secrets
```bash
# Create Secret from literal values
kubectl create secret generic db-secret --from-literal=username=admin --from-literal=password=secret -n microservices-app

# Create Secret from file
kubectl create secret generic ssl-cert --from-file=tls.crt --from-file=tls.key -n microservices-app

# View Secret (base64 encoded)
kubectl get secret db-secret -o yaml -n microservices-app
```

## Resource Monitoring

### Resource Usage
```bash
# Node resource usage
kubectl top nodes

# Pod resource usage
kubectl top pods -n microservices-app

# Pod resource usage with containers
kubectl top pods --containers -n microservices-app
```

### Events
```bash
# Get cluster events
kubectl get events

# Get namespace events
kubectl get events -n microservices-app

# Sort events by timestamp
kubectl get events --sort-by='.metadata.creationTimestamp' -n microservices-app
```

## Troubleshooting

### Common Debug Commands
```bash
# Check if pods are running
kubectl get pods -n microservices-app | grep -v Running

# Check pod events
kubectl describe pod <pod-name> -n microservices-app | grep Events -A 20

# Check service endpoints
kubectl get endpoints -n microservices-app

# Test DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup frontend.microservices-app.svc.cluster.local

# Test network connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -qO- http://frontend.microservices-app.svc.cluster.local:3000/health
```

### Performance and Debugging
```bash
# CPU and memory usage
kubectl top pods --sort-by=cpu -n microservices-app
kubectl top pods --sort-by=memory -n microservices-app

# Describe resource quotas
kubectl describe resourcequota -n microservices-app

# Check persistent volumes
kubectl get pv
kubectl get pvc -n microservices-app
```

## Helm Commands

### Chart Management
```bash
# Install a chart
helm install sample-app ./microservices-app -n microservices-app

# Upgrade a release
helm upgrade sample-app ./microservices-app -n microservices-app

# List releases
helm list -n microservices-app

# Get release status
helm status sample-app -n microservices-app

# Uninstall a release
helm uninstall sample-app -n microservices-app
```

### Chart Development
```bash
# Validate chart
helm lint ./microservices-app

# Render templates
helm template sample-app ./microservices-app

# Dry run installation
helm install sample-app ./microservices-app --dry-run -n microservices-app

# Package chart
helm package ./microservices-app
```

## Useful Aliases

Add these to your shell profile:

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'
alias kpf='kubectl port-forward'
```
