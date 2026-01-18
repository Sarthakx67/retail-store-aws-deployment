# 🛒 Retail Store Microservices - Helm Umbrella Chart

This repository contains the **Umbrella Helm Chart** for the Retail Store application, a microservices-based system including Cart, Catalog, Checkout, Orders, UI, and their supporting databases. This setup allows for single-command deployments, environment isolation (Dev/Prod), and automated scaling.

---

## 🛠️ Cluster Prerequisites & Setup

Before deploying, ensure your environment is correctly configured. These steps are essential for **k3s** and cloud-based lab environments.

### 1. **Kubernetes Context (k3s)**

The most critical line for a k3s setup is exporting your config so Helm and Kubectl can communicate with the API server.

```bash
# Export Kubeconfig (Required for every session)
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

```

*To make this permanent, add the line above to your `~/.bashrc` file.*

### 2. **Install Monitoring (Metrics Server)**

You must install the Metrics Server to enable `kubectl top` commands and Horizontal Pod Autoscaling (HPA).

```bash
# Install Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify installation (Wait 1-2 minutes for data to flow)
kubectl top nodes
kubectl top pods

```

### 3. **Install Helm CLI**

Helm is the package manager used to deploy the umbrella chart.

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

```

---

## 🚀 Deployment Guidee

### **Step 1: Prepare Dependencies**

The umbrella chart uses local sub-charts. You must link them before the first install.

```bash
# Run inside the umbrella-helm-chart directory
helm dependency update

```

### **Step 2: Set Your Environment Context**

Set your default namespace to avoid typing `-n` with every command.

```bash
# For Development
kubectl config set-context --current --namespace=retail-store-dev

# For Production
kubectl config set-context --current --namespace=retail-store-prod

```

### **Step 3: Start/Upgrade the Application**

Use a **Layered Values** strategy. `values.yaml` provides common defaults, while `-dev` or `-prod` files provide overrides.

#### **🟢 Start Development (DEV)**

* **Strategy**: Low resource limits, 1 replica per service.

```bash
helm upgrade --install retail-store . \
  -n retail-store-dev \
  -f values.yaml \
  -f values-dev.yaml \ 
  --create-namespace

```

#### **🔴 Start Production (PROD)**

* **Strategy**: High availability, 2-3 replicas per service, higher CPU/RAM.

```bash
helm upgrade --install retail-store . \
  -n retail-store-prod \
  -f values.yaml \
  -f values-prod.yaml \
  --create-namespace

```

---

## 🔍 Validation & Troubleshooting

### **Preview Changes (Dry-Run)**

To see exactly what YAML will be generated without deploying it, use the `template` command:

```bash
helm template retail-store . -f values.yaml -f values-prod.yaml

```

### **Common Debugging Commands**

* **Check Pod Status**: `kubectl get pods`
* **Check HPA/Scaling**: `kubectl get hpa`
* **Live Logs**: `kubectl logs -f deployment/retail-store-checkout`
* **Node Resources**: `kubectl top nodes`

---

## 🧹 Cleanup & Deletion

### **Uninstalling the App**

To remove the microservices and their configurations cleanly:

```bash
# Remove the Helm release
helm uninstall retail-store -n retail-store-dev

```

### **Resetting the Environment**

If you need to wipe everything, including namespaces and persistent volumes:

```bash
kubectl delete namespace retail-store-prod
# For k3s cleanup of old crashes
sudo coredumpctl purge

```

---

## 📂 Directory Structure

* **`charts/`**: Contains individual sub-charts (cart, catalog, etc.).
* **`Chart.yaml`**: Parent file defining all service dependencies.
* **`values.yaml`**: Shared baseline configuration.
* **`values-dev.yaml` / `values-prod.yaml**`: Environment-specific overrides.