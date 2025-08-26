# Helm Charts from Scratch: Step-by-Step Workshop

## 🎯 Workshop Overview

**Duration**: 2 hours  
**Level**: Intermediate  
**Prerequisites**: Kubernetes basics, completed workshops 01-04

This workshop teaches you how to create Helm charts from existing Kubernetes manifests, focusing on templating, values management, and best practices.

---

## 📚 Part 1: Understanding Helm Chart Structure (15 minutes)

### What is a Helm Chart?

A Helm chart is a collection of files that describe Kubernetes resources. Think of it as a "package" for your Kubernetes application.

**Key Components:**
- `Chart.yaml` - Chart metadata
- `values.yaml` - Default configuration values
- `templates/` - Kubernetes manifest templates
- `templates/_helpers.tpl` - Template helpers

### Step 1: Create a New Chart

```bash
cd /Users/shyam/repos/k8s-senior-dev-tutorial/05-helm-from-scratch

# Create a new chart
helm create my-microservices-chart
cd my-microservices-chart

# Examine the structure
tree .
```

### Step 2: Clean Up Generated Files

```bash
# Remove example files we don't need
rm -rf templates/tests/
rm templates/deployment.yaml
rm templates/service.yaml
rm templates/ingress.yaml
rm templates/hpa.yaml
rm templates/serviceaccount.yaml

# Keep Chart.yaml, values.yaml, _helpers.tpl, NOTES.txt
ls -la templates/
```

---

## 🛠️ Part 2: Converting Manifests to Templates (30 minutes)

### Step 3: Create Namespace Template

Let's start by converting our namespace manifest:

```bash
# Copy the original namespace manifest for reference
cp ../../03-k8s-manifests/00-namespace.yaml ./reference-namespace.yaml

# Create the template
cat > templates/namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .Values.namespace.name }}
  labels:
    {{- include "my-microservices-chart.labels" . | nindent 4 }}
EOF
```

### Step 4: Create MongoDB Template

```bash
# Copy original for reference
cp ../../03-k8s-manifests/01-mongodb.yaml ./reference-mongodb.yaml

# Create the template
cat > templates/mongodb.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-microservices-chart.fullname" . }}-mongodb
  namespace: {{ .Values.namespace.name }}
  labels:
    {{- include "my-microservices-chart.labels" . | nindent 4 }}
    app.kubernetes.io/component: mongodb
spec:
  replicas: {{ .Values.mongodb.replicaCount }}
  selector:
    matchLabels:
      {{- include "my-microservices-chart.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: mongodb
  template:
    metadata:
      labels:
        {{- include "my-microservices-chart.selectorLabels" . | nindent 8 }}
        app.kubernetes.io/component: mongodb
    spec:
      containers:
      - name: mongodb
        image: "{{ .Values.mongodb.image.repository }}:{{ .Values.mongodb.image.tag }}"
        ports:
        - containerPort: 27017
        volumeMounts:
        - name: mongodb-data
          mountPath: /data/db
        {{- if .Values.mongodb.resources }}
        resources:
          {{- toYaml .Values.mongodb.resources | nindent 10 }}
        {{- end }}
      volumes:
      - name: mongodb-data
        persistentVolumeClaim:
          claimName: {{ include "my-microservices-chart.fullname" . }}-mongodb-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "my-microservices-chart.fullname" . }}-mongodb
  namespace: {{ .Values.namespace.name }}
  labels:
    {{- include "my-microservices-chart.labels" . | nindent 4 }}
    app.kubernetes.io/component: mongodb
spec:
  selector:
    {{- include "my-microservices-chart.selectorLabels" . | nindent 4 }}
    app.kubernetes.io/component: mongodb
  ports:
  - port: 27017
    targetPort: 27017
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "my-microservices-chart.fullname" . }}-mongodb-pvc
  namespace: {{ .Values.namespace.name }}
  labels:
    {{- include "my-microservices-chart.labels" . | nindent 4 }}
    app.kubernetes.io/component: mongodb
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.mongodb.persistence.size }}
EOF
```

**🔍 Key Templating Concepts:**

- `{{ .Values.something }}` - References values.yaml
- `{{ include "templatename" . }}` - Includes helper templates
- `{{- toYaml .Values.resources | nindent 10 }}` - YAML formatting
- `{{- if .Values.condition }}` - Conditional logic

---

## ⚙️ Part 3: Configuring Values (25 minutes)

### Step 5: Create values.yaml

```bash
cat > values.yaml << 'EOF'
# Global settings
namespace:
  name: microservices-app

# MongoDB configuration
mongodb:
  replicaCount: 1
  image:
    repository: mongo
    tag: "4.4"
  persistence:
    size: 1Gi
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 128Mi

# PostgreSQL configuration
postgresql:
  replicaCount: 1
  image:
    repository: postgres
    tag: "13"
  auth:
    database: products
    username: postgres
    password: password123
  persistence:
    size: 1Gi
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 128Mi

# Redis configuration
redis:
  replicaCount: 1
  image:
    repository: redis
    tag: "6-alpine"
  resources:
    limits:
      cpu: 200m
      memory: 256Mi
    requests:
      cpu: 50m
      memory: 64Mi

# User Service configuration
userService:
  replicaCount: 2
  image:
    repository: user-service
    tag: latest
  port: 3001
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 128Mi

# Product Service configuration
productService:
  replicaCount: 2
  image:
    repository: product-service
    tag: latest
  port: 5001
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 128Mi

# API Gateway configuration
apiGateway:
  replicaCount: 2
  image:
    repository: api-gateway
    tag: latest
  port: 8080
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 128Mi

# Frontend configuration
frontend:
  replicaCount: 2
  image:
    repository: frontend
    tag: latest
  port: 3000
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 128Mi

# Ingress configuration
ingress:
  enabled: true
  className: nginx
  host: microservices.local
EOF
```

### Step 6: Update Chart.yaml

```bash
cat > Chart.yaml << 'EOF'
apiVersion: v2
name: my-microservices-chart
description: A Helm chart for microservices application
type: application
version: 0.1.0
appVersion: "1.0"
keywords:
  - microservices
  - api
  - nodejs
  - python
  - mongodb
  - postgresql
  - redis
maintainers:
  - name: Your Name
    email: your.email@example.com
sources:
  - https://github.com/your-repo/microservices-app
EOF
```

---

## 🔧 Part 4: Creating More Templates (35 minutes)

### Step 7: PostgreSQL Template

```bash
cat > templates/postgresql.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "my-microservices-chart.fullname" . }}-postgres-secret
  namespace: {{ .Values.namespace.name }}
  labels:
    {{- include "my-microservices-chart.labels" . | nindent 4 }}
    app.kubernetes.io/component: postgresql
type: Opaque
data:
  POSTGRES_DB: {{ .Values.postgresql.auth.database | b64enc }}
  POSTGRES_USER: {{ .Values.postgresql.auth.username | b64enc }}
  POSTGRES_PASSWORD: {{ .Values.postgresql.auth.password | b64enc }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-microservices-chart.fullname" . }}-postgresql
  namespace: {{ .Values.namespace.name }}
  labels:
    {{- include "my-microservices-chart.labels" . | nindent 4 }}
    app.kubernetes.io/component: postgresql
spec:
  replicas: {{ .Values.postgresql.replicaCount }}
  selector:
    matchLabels:
      {{- include "my-microservices-chart.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: postgresql
  template:
    metadata:
      labels:
        {{- include "my-microservices-chart.selectorLabels" . | nindent 8 }}
        app.kubernetes.io/component: postgresql
    spec:
      containers:
      - name: postgresql
        image: "{{ .Values.postgresql.image.repository }}:{{ .Values.postgresql.image.tag }}"
        ports:
        - containerPort: 5432
        envFrom:
        - secretRef:
            name: {{ include "my-microservices-chart.fullname" . }}-postgres-secret
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        {{- if .Values.postgresql.resources }}
        resources:
          {{- toYaml .Values.postgresql.resources | nindent 10 }}
        {{- end }}
      volumes:
      - name: postgres-data
        persistentVolumeClaim:
          claimName: {{ include "my-microservices-chart.fullname" . }}-postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "my-microservices-chart.fullname" . }}-postgresql
  namespace: {{ .Values.namespace.name }}
  labels:
    {{- include "my-microservices-chart.labels" . | nindent 4 }}
    app.kubernetes.io/component: postgresql
spec:
  selector:
    {{- include "my-microservices-chart.selectorLabels" . | nindent 4 }}
    app.kubernetes.io/component: postgresql
  ports:
  - port: 5432
    targetPort: 5432
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "my-microservices-chart.fullname" . }}-postgres-pvc
  namespace: {{ .Values.namespace.name }}
  labels:
    {{- include "my-microservices-chart.labels" . | nindent 4 }}
    app.kubernetes.io/component: postgresql
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.postgresql.persistence.size }}
EOF
```

### Step 8: Create Service Template (Generic Pattern)

Let's create a reusable template for our microservices:

```bash
cat > templates/user-service.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-microservices-chart.fullname" . }}-user-service
  namespace: {{ .Values.namespace.name }}
  labels:
    {{- include "my-microservices-chart.labels" . | nindent 4 }}
    app.kubernetes.io/component: user-service
spec:
  replicas: {{ .Values.userService.replicaCount }}
  selector:
    matchLabels:
      {{- include "my-microservices-chart.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: user-service
  template:
    metadata:
      labels:
        {{- include "my-microservices-chart.selectorLabels" . | nindent 8 }}
        app.kubernetes.io/component: user-service
    spec:
      containers:
      - name: user-service
        image: "{{ .Values.userService.image.repository }}:{{ .Values.userService.image.tag }}"
        ports:
        - containerPort: {{ .Values.userService.port }}
        env:
        - name: MONGODB_URI
          value: "mongodb://{{ include "my-microservices-chart.fullname" . }}-mongodb:27017/users"
        livenessProbe:
          httpGet:
            path: /health
            port: {{ .Values.userService.port }}
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: {{ .Values.userService.port }}
          initialDelaySeconds: 5
          periodSeconds: 5
        {{- if .Values.userService.resources }}
        resources:
          {{- toYaml .Values.userService.resources | nindent 10 }}
        {{- end }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "my-microservices-chart.fullname" . }}-user-service
  namespace: {{ .Values.namespace.name }}
  labels:
    {{- include "my-microservices-chart.labels" . | nindent 4 }}
    app.kubernetes.io/component: user-service
spec:
  selector:
    {{- include "my-microservices-chart.selectorLabels" . | nindent 4 }}
    app.kubernetes.io/component: user-service
  ports:
  - port: {{ .Values.userService.port }}
    targetPort: {{ .Values.userService.port }}
EOF
```

### Step 9: Create Advanced Helper Templates

Update the `_helpers.tpl` file with useful functions:

```bash
cat > templates/_helpers.tpl << 'EOF'
{{/*
Expand the name of the chart.
*/}}
{{- define "my-microservices-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "my-microservices-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "my-microservices-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "my-microservices-chart.labels" -}}
helm.sh/chart: {{ include "my-microservices-chart.chart" . }}
{{ include "my-microservices-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "my-microservices-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-microservices-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "my-microservices-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "my-microservices-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate database connection string for services
*/}}
{{- define "my-microservices-chart.mongodbConnectionString" -}}
mongodb://{{ include "my-microservices-chart.fullname" . }}-mongodb:27017
{{- end }}

{{- define "my-microservices-chart.postgresConnectionString" -}}
postgresql://{{ .Values.postgresql.auth.username }}:{{ .Values.postgresql.auth.password }}@{{ include "my-microservices-chart.fullname" . }}-postgresql:5432/{{ .Values.postgresql.auth.database }}
{{- end }}
EOF
```

---

## 🧪 Part 5: Testing and Validation (20 minutes)

### Step 10: Template Validation

```bash
# Validate the chart syntax
helm lint .

# Generate templates to see the output
helm template my-app . --namespace microservices-app

# Generate specific template
helm template my-app . --show-only templates/mongodb.yaml

# Debug with values
helm template my-app . --set mongodb.replicaCount=3 --debug
```

### Step 11: Dry Run Installation

```bash
# Ensure Kind cluster is running
kubectl cluster-info

# Dry run to see what would be created
helm install my-microservices-app . --namespace microservices-app --create-namespace --dry-run --debug

# Check for any template errors
helm template my-microservices-app . | kubectl apply --dry-run=client -f -
```

### Step 12: Package the Chart

```bash
# Move up one directory
cd ..

# Package the chart
helm package my-microservices-chart/

# List the created package
ls -la *.tgz

# Verify the package
helm show chart my-microservices-chart-0.1.0.tgz
helm show values my-microservices-chart-0.1.0.tgz
```

---

## 🚀 Part 6: Advanced Templating Techniques (15 minutes)

### Step 13: Conditional Templates

Create a template with conditional logic:

```bash
cd my-microservices-chart

cat > templates/ingress.yaml << 'EOF'
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "my-microservices-chart.fullname" . }}-ingress
  namespace: {{ .Values.namespace.name }}
  labels:
    {{- include "my-microservices-chart.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  rules:
  - host: {{ .Values.ingress.host }}
    http:
      paths:
      - path: /api/users
        pathType: Prefix
        backend:
          service:
            name: {{ include "my-microservices-chart.fullname" . }}-user-service
            port:
              number: {{ .Values.userService.port }}
      - path: /api/products
        pathType: Prefix
        backend:
          service:
            name: {{ include "my-microservices-chart.fullname" . }}-product-service
            port:
              number: {{ .Values.productService.port }}
      - path: /api/gateway
        pathType: Prefix
        backend:
          service:
            name: {{ include "my-microservices-chart.fullname" . }}-api-gateway
            port:
              number: {{ .Values.apiGateway.port }}
      - path: /
        pathType: Prefix
        backend:
          service:
            name: {{ include "my-microservices-chart.fullname" . }}-frontend
            port:
              number: {{ .Values.frontend.port }}
{{- end }}
EOF
```

### Step 14: Named Templates for Reusability

Add reusable templates to `_helpers.tpl`:

```bash
cat >> templates/_helpers.tpl << 'EOF'

{{/*
Standard deployment template
*/}}
{{- define "my-microservices-chart.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-microservices-chart.fullname" . }}-{{ .componentName }}
  namespace: {{ .Values.namespace.name }}
  labels:
    {{- include "my-microservices-chart.labels" . | nindent 4 }}
    app.kubernetes.io/component: {{ .componentName }}
spec:
  replicas: {{ .component.replicaCount }}
  selector:
    matchLabels:
      {{- include "my-microservices-chart.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: {{ .componentName }}
  template:
    metadata:
      labels:
        {{- include "my-microservices-chart.selectorLabels" . | nindent 8 }}
        app.kubernetes.io/component: {{ .componentName }}
    spec:
      containers:
      - name: {{ .componentName }}
        image: "{{ .component.image.repository }}:{{ .component.image.tag }}"
        ports:
        - containerPort: {{ .component.port }}
        {{- if .component.resources }}
        resources:
          {{- toYaml .component.resources | nindent 10 }}
        {{- end }}
{{- end }}
EOF
```

---

## 🎯 Part 7: Best Practices and Deployment (10 minutes)

### Step 15: Final Chart Testing

```bash
# Full template validation
helm template my-microservices-app . --validate

# Install the chart
helm install my-microservices-app . --namespace microservices-app --create-namespace

# Check the deployment
helm list -n microservices-app
kubectl get all -n microservices-app

# Test with different values
helm upgrade my-microservices-app . --set userService.replicaCount=3 -n microservices-app

# Rollback if needed
helm rollback my-microservices-app 1 -n microservices-app
```

### Step 16: Chart Documentation

Create a comprehensive README for your chart:

```bash
cat > CHART-README.md << 'EOF'
# My Microservices Helm Chart

## Overview
This Helm chart deploys a complete microservices application with:
- Frontend (React)
- API Gateway (Express.js)
- User Service (Node.js + MongoDB)
- Product Service (Python + PostgreSQL)
- Redis cache

## Installation

```bash
helm install my-app ./my-microservices-chart --namespace microservices-app --create-namespace
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespace.name` | Namespace for deployment | `microservices-app` |
| `mongodb.replicaCount` | MongoDB replicas | `1` |
| `postgresql.auth.password` | PostgreSQL password | `password123` |
| `userService.replicaCount` | User service replicas | `2` |

## Custom Values

```yaml
# values-production.yaml
userService:
  replicaCount: 5
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi

postgresql:
  auth:
    password: "secure-password"
  persistence:
    size: 10Gi
```

Install with custom values:
```bash
helm install my-app ./my-microservices-chart -f values-production.yaml
```
EOF
```

---

## 🎉 Workshop Summary

### What You've Learned:

1. **Chart Structure**: Understanding Helm chart components
2. **Templating**: Using Go templates with Kubernetes YAML
3. **Values Management**: Parameterizing configurations
4. **Helper Templates**: Creating reusable template functions
5. **Conditional Logic**: Adding flexibility to templates
6. **Validation**: Testing and debugging charts
7. **Packaging**: Creating distributable chart packages
8. **Best Practices**: Documentation and organization

### Key Templating Patterns:

```yaml
# Values reference
{{ .Values.path.to.value }}

# Include helpers
{{ include "chart.fullname" . }}

# Conditional blocks
{{- if .Values.ingress.enabled }}
...
{{- end }}

# Loops
{{- range .Values.items }}
- {{ . }}
{{- end }}

# YAML formatting
{{- toYaml .Values.resources | nindent 8 }}

# Base64 encoding
{{ .Values.password | b64enc }}
```

### Next Steps:

1. **Chart Repository**: Publish to a Helm repository
2. **Subchart Dependencies**: Use external charts as dependencies
3. **Chart Testing**: Implement chart tests
4. **Advanced Templating**: Named templates, complex logic
5. **Helm Hooks**: Pre/post-install hooks
6. **Security**: RBAC, Pod Security Standards

---

## 🔧 Quick Reference

### Essential Helm Commands

```bash
# Create chart
helm create mychart

# Validate chart
helm lint ./mychart

# Template preview
helm template myrelease ./mychart

# Install
helm install myrelease ./mychart

# Upgrade
helm upgrade myrelease ./mychart

# Rollback
helm rollback myrelease 1

# Uninstall
helm uninstall myrelease

# Package
helm package ./mychart

# Show chart info
helm show chart ./mychart
helm show values ./mychart
```

### Template Functions

```yaml
# String manipulation
{{ .Values.name | upper }}
{{ .Values.name | lower }}
{{ .Values.name | title }}
{{ .Values.name | quote }}

# Encoding
{{ .Values.secret | b64enc }}
{{ .Values.data | toJson }}
{{ .Values.config | toYaml }}

# Default values
{{ .Values.optional | default "default-value" }}

# Conditionals
{{ if .Values.enabled }}enabled{{ else }}disabled{{ end }}
```

**🎉 Congratulations! You can now create Helm charts from scratch!**
