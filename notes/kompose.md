# Docker Compose → Kubernetes → Helm (Developer-Friendly Guide)

Start with a single `docker-compose.yml` and generate both K8s manifests and a Helm chart effortlessly.

---

## Prerequisites

- A `docker-compose.yml` in your project repo  
- **kompose** installed (`brew`, `curl` from GitHub releases, etc.)  
- **helm** CLI installed  
- Configured Kubernetes cluster (`kubectl` ready)

---

## 1) Quick: Compose → Kubernetes YAML

```bash
kompose convert -f docker-compose.yml -o k8s/
```
This produces Kubernetes YAML files (e.g. deployment.yaml, service.yaml, etc.) under the k8s/ directory.

Apply them:
```bash
kubectl apply -f k8s/
kubectl get all
```
Kompose automates most conversions (~99% accurate)—supporting services, volumes, ports, and more.



---

## 2) Quick: Compose → Helm Chart

```bash
kompose convert -c -f docker-compose.yml -o helm/
```
This produces a Helm chart under the helm/ directory.

Install the chart:
```bash
helm install my-release helm/
```
