# 05-helm-from-scratch

This directory contains resources for learning how to create Helm charts from scratch, converting existing Kubernetes manifests into parameterized, reusable charts.

## 📁 Directory Structure

```
05-helm-from-scratch/
├── README.md                           # This file
├── helm-from-scratch-workshop.md       # Complete workshop guide (2 hours)
├── scripts/
│   ├── create-chart.sh                 # Script to initialize new chart
│   └── validate-chart.sh               # Script to validate and test chart
└── examples/                           # Will contain sample charts
    └── my-microservices-chart/         # Generated during workshop
```

## 🎯 Learning Objectives

- **Chart Creation**: Initialize and structure Helm charts
- **Template Conversion**: Transform YAML manifests into Go templates
- **Values Management**: Create flexible configuration with values.yaml
- **Helper Templates**: Build reusable template functions
- **Testing & Validation**: Ensure chart quality and correctness
- **Best Practices**: Follow Helm community standards

## � Quick Start

### Prerequisites
- Completed workshops 01-04
- Helm 3.x installed
- Running Kubernetes cluster (Kind)

### Create Your First Chart

```bash
cd 05-helm-from-scratch/scripts
./create-chart.sh
```

### Follow the Workshop

Open `helm-from-scratch-workshop.md` and follow the step-by-step guide.

### Validate Your Work

```bash
./validate-chart.sh
```

## � Key Concepts Covered

### 1. Chart Structure
- `Chart.yaml` - Metadata and dependencies
- `values.yaml` - Default configuration
- `templates/` - Kubernetes manifest templates
- `templates/_helpers.tpl` - Reusable template functions

### 2. Template Syntax
```yaml
# Values reference
{{ .Values.mongodb.replicaCount }}

# Helper function calls
{{ include "chart.fullname" . }}

# Conditional logic
{{- if .Values.ingress.enabled }}
...
{{- end }}

# YAML formatting
{{- toYaml .Values.resources | nindent 8 }}
```

### 3. Advanced Patterns
- Named templates for reusability
- Conditional resource creation
- Value validation and defaults
- Multi-environment configuration

## 🛠️ Workshop Flow

1. **Setup** (15 min) - Chart initialization and cleanup
2. **Basic Templates** (30 min) - Convert simple manifests
3. **Values Configuration** (25 min) - Create flexible configuration
4. **Advanced Templates** (35 min) - Services, secrets, and patterns
5. **Testing** (20 min) - Validation and dry-run
6. **Advanced Techniques** (15 min) - Conditional logic and helpers
7. **Best Practices** (10 min) - Documentation and packaging

## 🎯 Expected Outcomes

After completing this workshop, you'll be able to:

- ✅ Create Helm charts from existing Kubernetes manifests
- ✅ Use Go template syntax effectively
- ✅ Design flexible, reusable charts
- ✅ Implement chart testing and validation
- ✅ Package and distribute charts
- ✅ Follow Helm best practices

## 🔗 Related Resources

- **Workshop 04**: `/04-helm-charts/` - Using existing charts
- **Original Manifests**: `/03-k8s-manifests/` - Source material
- **Sample App**: `/sample-app/` - Application being chartified

## 📖 Additional Reading

- [Helm Official Documentation](https://helm.sh/docs/)
- [Chart Template Guide](https://helm.sh/docs/chart_template_guide/)
- [Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Go Template Reference](https://pkg.go.dev/text/template)

---

**Ready to master Helm chart creation? Start with the workshop guide!** 🚀
