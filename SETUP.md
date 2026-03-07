# 🛒 AWS Retail Store - Cloud-Native Microservices Deployment

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)

> **Production-grade microservices deployment on AWS EKS using Kubernetes, Helm, IRSA, HPA, and persistent storage.**

---

## 📋 Table of Contents

- [Prerequisites](#-prerequisites)
- [EKS Deployment](#-eks-deployment)
- [IRSA Setup for DynamoDB](#-irsa-setup-for-dynamodb)
- [Monitoring with Prometheus & Grafana](#-monitoring-with-prometheus--grafana)
- [Useful Commands Cheatsheet](#-useful-commands-cheatsheet)
- [Troubleshooting](#-troubleshooting)
- [Full Deployment Order](#-full-deployment-order-run-this-to-avoid-errors)
- [Cleanup](#-cleanup)

---

**Key Design Decisions:**
- Cart service uses DynamoDB via IRSA (no static credentials)
- Health probes reduced deployment time from **~12 minutes → ~1.5 minutes**
- HPA configured on all services (target: 70% CPU utilization)

---

## ✅ Prerequisites

```bash
# Required tools
- Docker 24+
- kubectl 1.28+
- Helm 3.14+
- AWS CLI (configured)
- eksctl
```

---

## 🌩️ EKS Deployment

> Covers both **dev** (`retail-store-dev`) and **prod** (`retail-store-prod`) environments on AWS EKS.

### Step 1: Create EKS Cluster

Create `eks.yaml`:

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: retail-store-cluster
  region: ap-south-1
  version: "1.28"

nodeGroups:
  - name: retail-store-nodes
    instanceType: t3.medium
    desiredCapacity: 3
    minSize: 2
    maxSize: 5
    volumeSize: 20
    ssh:
      allow: true
      publicKeyName: your-ec2-key
    iam:
      withAddonPolicies:
        ebs: true
        efs: true
        albIngress: true
```

```bash
eksctl create cluster --config-file=eks.yaml
# Takes 15-20 minutes
```

### Step 2: Configure kubectl

```bash
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name retail-store-cluster

kubectl get nodes       # Verify connection
kubectl cluster-info
```

### Step 3: Install EKS Add-ons

#### Metrics Server (Required for HPA)

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl wait --for=condition=available deployment/metrics-server -n kube-system --timeout=300s
kubectl top nodes  # Should return metrics
```

#### AWS EBS CSI Driver (Required for Persistent Volumes)

```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.25"

# Attach EBS CSI policy to node role
NODE_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName,'nodegroup')].RoleName" --output text | head -1)
aws iam attach-role-policy \
  --role-name $NODE_ROLE \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy

kubectl get pods -n kube-system | grep ebs-csi  # Verify
```

### Step 4: Deploy with Helm

```bash
cd retail-store-helm-chart
helm dependency update

# Dry run first
helm template retail-store . \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml \
  --namespace retail-store-prod

# Deploy
helm upgrade --install retail-store . \
  -n retail-store-prod \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml \
  --create-namespace \
  --timeout 10m
```

### Step 5: Verify Deployment

```bash
helm list -n retail-store-prod
kubectl get pods -n retail-store-prod     # All should be Running
kubectl get svc -n retail-store-prod
kubectl get hpa -n retail-store-prod
kubectl get pvc -n retail-store-prod
```

### Step 6: Access the Application

```bash
# Get LoadBalancer URL (wait for EXTERNAL-IP)
kubectl get svc ui -n retail-store-prod

# Print full URL
echo "http://$(kubectl get svc ui -n retail-store-prod -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

---

## 🔐 IRSA Setup for DynamoDB

> Allows the Cart service to access DynamoDB **without static AWS credentials**.

### 1. Create DynamoDB Table

```bash
aws dynamodb create-table \
  --table-name Items \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1

# Verify
aws dynamodb describe-table --table-name Items --region ap-south-1 \
  --query 'Table.[TableName,TableStatus,ItemCount]'
# Expected: ["Items", "ACTIVE", 0]
```

### 2. Enable OIDC Provider

```bash
eksctl utils associate-iam-oidc-provider \
  --cluster retail-store-cluster \
  --approve

# Verify
aws iam list-open-id-connect-providers
```

### 3. Create IAM Policy for DynamoDB

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

cat > cart-dynamodb-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem",
      "dynamodb:DeleteItem", "dynamodb:Query", "dynamodb:Scan"
    ],
    "Resource": "arn:aws:dynamodb:ap-south-1:${ACCOUNT_ID}:table/Items"
  }]
}
EOF

aws iam create-policy \
  --policy-name cart-dynamodb-policy \
  --policy-document file://cart-dynamodb-policy.json

POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/cart-dynamodb-policy"
```

### 4. Create IAM Role with Trust Relationship

```bash
OIDC_URL=$(aws eks describe-cluster \
  --name retail-store-cluster \
  --query "cluster.identity.oidc.issuer" --output text)

OIDC_ID=$(echo $OIDC_URL | cut -d '/' -f 5)

cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/oidc.eks.ap-south-1.amazonaws.com/id/${OIDC_ID}"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "oidc.eks.ap-south-1.amazonaws.com/id/${OIDC_ID}:sub": "system:serviceaccount:retail-store-prod:cart-sa"
      }
    }
  }]
}
EOF

aws iam create-role \
  --role-name cart-dynamodb-role \
  --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
  --role-name cart-dynamodb-role \
  --policy-arn $POLICY_ARN
```

### 5. Update Helm Values

Edit `values/eks/values-prod-eks.yaml`:

```yaml
retail-store-cart:
  aws:
    authMethod: irsa
  serviceAccount:
    name: cart-sa
    roleArn: arn:aws:iam::YOUR_ACCOUNT_ID:role/cart-dynamodb-role  # ← update this
```

### 6. Verify IRSA

```bash
kubectl get sa cart-sa -n retail-store-prod -o yaml
# Should show: eks.amazonaws.com/role-arn annotation

kubectl exec -it deployment/cart-deployment -n retail-store-prod -- env | grep AWS
# Expected: AWS_ROLE_ARN, AWS_WEB_IDENTITY_TOKEN_FILE, AWS_REGION

kubectl logs deployment/cart-deployment -n retail-store-prod
# No AccessDenied errors = IRSA working correctly
```

---

## 📊 Monitoring with Prometheus & Grafana

```bash
# Create namespace
kubectl create namespace monitoring

# Add Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring

# Verify
kubectl get pods -n monitoring
```

### Access Grafana (SSH Tunnel from Local Machine)

**Step 1: SSH with port forwarding**

```bash
ssh -i EC2-key.pem -L 3000:localhost:3000 ec2-user@<EC2-IP>
```

**Step 2: On EC2, port-forward Grafana**

```bash
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
# For Prometheus:
kubectl port-forward svc/prometheus-operated 9090:9090 -n monitoring
```

**Step 3: Open in browser**

```
http://localhost:3000
```

**Grafana credentials:**

```bash
# Get password
kubectl get secret monitoring-grafana -n monitoring \
  -o jsonpath="{.data.admin-password}" | base64 -d

# Username: admin
```

---

## 📘 Useful Commands Cheatsheet

```bash
# --- Cluster ---
kubectl get nodes
kubectl cluster-info
kubectl top nodes
kubectl top pods -n retail-store-prod

# --- App Status ---
kubectl get pods -n retail-store-prod
kubectl get svc -n retail-store-prod
kubectl get hpa -n retail-store-prod
kubectl get events -n retail-store-prod --sort-by='.lastTimestamp'

# --- Logs ---
kubectl logs -f deployment/cart-deployment -n retail-store-prod
kubectl logs -f deployment/ui -n retail-store-prod

# --- Storage ---
kubectl get sc
kubectl get pvc -n retail-store-prod
kubectl get pv
kubectl describe pvc mysql-data-mysql-0 -n retail-store-prod

# --- Helm ---
helm list -n retail-store-prod
helm dependency update
helm upgrade retail-store ./retail-store-helm-chart -n retail-store-dev

# --- Rollout ---
kubectl rollout restart deploy cart-deployment -n retail-store-dev

# --- Debug Shell ---
kubectl exec -it deployment/cart-deployment -n retail-store-prod -- /bin/sh
kubectl port-forward svc/ui 8080:80 -n retail-store-prod

# --- MySQL ---
kubectl exec -it mysql-0 -n retail-store-prod -- bash
# mysql -u root -p
# SHOW DATABASES;

# --- PostgreSQL ---
kubectl exec -it postgresql-0 -n retail-store-prod -- bash
# psql -U postgres_user -d postgres
# \l          → list databases
# \c orders   → connect to orders db
# \dt         → list tables
# SELECT * FROM orders;

# --- IRSA Debug ---
aws iam list-open-id-connect-providers
aws iam get-role --role-name cart-dynamodb-role
kubectl get sa cart-sa -n retail-store-prod -o yaml
aws dynamodb describe-table --table-name Items --region ap-south-1
```

---

## 🔍 Troubleshooting

| Issue | Commands | Common Causes |
|-------|----------|---------------|
| Pod CrashLoopBackOff | `kubectl logs <pod> --previous` `kubectl describe pod <pod>` | Missing EBS CSI driver, bad IAM config, DynamoDB table missing |
| PVC Pending | `kubectl describe pvc <name>` `kubectl get sc` | EBS CSI not installed, IAM permissions missing |
| LoadBalancer Pending | `kubectl describe svc ui` | Subnet IP exhaustion, security group issue |
| IRSA Auth Failures | `kubectl logs deploy/cart-deployment` | OIDC not enabled, wrong trust relationship, missing SA annotation |
| DynamoDB Access Denied | `kubectl exec ... -- env \| grep AWS` | Static credentials conflicting with IRSA, wrong region/table |

---

## 🚀 Correct Deployment Order

> Follow this sequence to avoid errors. Each step links to the relevant section above.

| # | Step | Why it matters |
|---|------|---------------|
| 1 | [Create EKS Cluster](#step-1-create-eks-cluster) | Everything depends on this |
| 2 | [Configure kubectl](#step-2-configure-kubectl) | Required before any `kubectl` commands |
| 3 | [Install Metrics Server](#metrics-server-required-for-hpa) | Must exist before HPA can function |
| 4 | [Install EBS CSI Driver](#aws-ebs-csi-driver-required-for-persistent-volumes) | Must exist before PVCs are created — deploying the app first will leave them stuck in `Pending` |
| 5 | [Create DynamoDB Table](#1-create-dynamodb-table) | Table must be `ACTIVE` before the Cart pod starts, or it will crash |
| 6 | [IRSA Setup](#-irsa-setup-for-dynamodb) | ServiceAccount annotation must exist before app deploy, not after |
| 7 | [Update Helm values](#5-update-helm-values) | Set the correct `roleArn` before deploying |
| 8 | [Install Monitoring](#-monitoring-with-prometheus--grafana) | Create the `monitoring` namespace before running `helm install` |
| 9 | [Deploy App with Helm](#step-4-deploy-with-helm) | Run `helm template` dry-run first to catch config errors |
| 10 | [Verify](#step-5-verify-deployment) | Confirm pods Running, PVCs Bound, HPA active, no AccessDenied in cart logs |

---

## 🧹 Cleanup

### App Only

```bash
helm uninstall retail-store -n retail-store-prod
kubectl delete namespace retail-store-prod
# PVs are auto-deleted (ReclaimPolicy: Delete)
```

### Full AWS Cleanup

```bash
# App
helm uninstall retail-store -n retail-store-prod
kubectl delete namespace retail-store-prod

# DynamoDB
aws dynamodb delete-table --table-name Items --region ap-south-1

# IAM
aws iam detach-role-policy \
  --role-name cart-dynamodb-role \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/cart-dynamodb-policy
aws iam delete-role --role-name cart-dynamodb-role
aws iam delete-policy \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/cart-dynamodb-policy

# EKS Cluster
eksctl delete cluster --config-file=eks.yaml
```

---

## 📚 Resources

- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [IRSA Setup Guide](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Helm Docs](https://helm.sh/docs/)

---

<div align="center">

**⭐ Star this repo if you find it helpful!**

Made with ❤️ for the DevOps community

</div>