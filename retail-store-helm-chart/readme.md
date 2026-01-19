# 🛒 Retail Store Microservices – Helm Umbrella Chart

This repository contains the **Umbrella Helm Chart** for the Retail Store application — a microservices-based system including **Cart, Catalog, Checkout, Orders, UI**, and **supporting infrastructure** (DynamoDB-local, MySQL, Redis, RabbitMQ).

The setup enables:

* Single-command deployments
* Clean **K3s (local)** vs **EKS (production)** separation
* Environment isolation
* Horizontal Pod Autoscaling (HPA)
* Secure AWS access using **IRSA** in production

---

## 🛠️ Cluster Prerequisites & Setup

### 1️⃣ Kubernetes Context (K3s)

For K3s, you **must export the kubeconfig** so Helm and kubectl can talk to the cluster.

```bash
# Required for every session
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

📌 *To make this permanent, add it to `~/.bashrc` or `~/.zshrc`.*

---

### 2️⃣ Install Metrics Server (Required for HPA)

Metrics Server is mandatory for:

* `kubectl top`
* Horizontal Pod Autoscaling (HPA)

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify (wait ~1–2 minutes)
kubectl top nodes
kubectl top pods
```

---

### 3️⃣ Install Helm CLI

Helm is used to deploy the umbrella chart and manage releases.

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

---

## 🚀 Deployment Guide

### 📌 Step 1: Prepare Dependencies

The umbrella chart uses **local subcharts**. This must be done once (or after chart changes).

```bash
# Run inside the umbrella-helm-chart directory
helm dependency update
```

---

### 📌 Step 2: (Optional) Set Default Namespace

This avoids typing `-n` repeatedly.

```bash
# Development (K3s)
kubectl config set-context --current --namespace=retail-store-dev

# Production (EKS)
kubectl config set-context --current --namespace=retail-store-prod
```

---

## ▶️ Step 3: Deploy Using Environment-Specific Values

Helm uses **layered values**:

```
values.yaml                  → base (env-agnostic)
values/k3s/values-k3s.yaml   → local dev overrides
values/eks/values-eks.yaml   → production overrides
```

---

## 🟢 Start Development Environment (K3s)

### Strategy

* DynamoDB **local pod enabled**
* Static AWS credentials (fake/local)
* NodePort for UI
* Lower resource usage

```bash
helm upgrade --install retail-store . \
  -n retail-store-dev \
  -f values.yaml \
  -f values/k3s/values-dev-k3s.yaml \
  --create-namespace
```

✔ DynamoDB-local pod created
✔ UI exposed via NodePort
✔ Safe for local development

---

## 🔴 Start Production Environment (EKS)

### Strategy

* **No DynamoDB pod** (uses AWS DynamoDB)
* Secure access via **IRSA**
* ClusterIP services + Ingress/ALB
* Production-grade scaling

```bash
helm upgrade --install retail-store . \
  -n retail-store-prod \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml \
  --create-namespace
```

✔ No local databases
✔ No AWS secrets in Git
✔ Fully production-safe

---

## 🔍 Validation & Troubleshooting

### 🔎 Dry Run / Preview Rendered YAML

Always validate before applying to prod:

```bash
helm template retail-store . \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml
```

```bash
helm template retail-store . \
  -f values.yaml \
  -f values/k3s/values-dev-k3s.yaml
```

---

### 🛠 Common Debugging Commands

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
kubectl logs -f deployment/cart-deployment
kubectl top nodes
kubectl top pods
```

---

## 🧹 Cleanup & Deletion

### Uninstall the Application

```bash
helm uninstall retail-store -n retail-store-dev
```

---

### Full Environment Cleanup

```bash
kubectl delete namespace retail-store-prod

# (K3s only) cleanup old crash dumps
sudo coredumpctl purge
```

---

## 📂 Directory Structure (Final)

```
umbrella-helm-chart/
├── Chart.yaml                 # Umbrella chart & dependencies
├── values.yaml                # Base values (env-agnostic)
├── values/
│   ├── k3s/
│   │   ├── values-dev-k3s.yaml
│   │   ├── values-prod-k3s.yaml
│   └── eks/
│       ├── values-dev-eks.yaml
│       ├── values-prod-eks.yaml
├── charts/
│   ├── cart/
│   ├── catalog/
│   ├── checkout/
│   ├── orders/
│   ├── ui/
│   ├── dynamodb/              # Local-only (K3s)
│   ├── mysql/
│   ├── redis/
│   └── rabbitmq/
```

---

## 🧠 Key Design Principle (Important)

> **Subcharts are environment-agnostic.
> Environment behavior is controlled only via umbrella values files.**

This design is:

* GitOps-friendly
* ArgoCD-ready
* Interview-grade
* Production-safe

