# 🛒 AWS Retail Store - Cloud-Native Microservices Deployment

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)

> **Production-grade microservices deployment showcasing multiple infrastructure patterns, from manual EC2 provisioning to automated Kubernetes orchestration with Helm on AWS EKS.**

This repository demonstrates a complete DevOps journey for deploying a retail store application using modern cloud-native practices. It includes four distinct deployment strategies, each solving different operational challenges.

---

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Deployment Strategies](#-deployment-strategies)
- [Technology Stack](#-technology-stack)
- [Quick Start](#-quick-start)
- [EKS Production Deployment](#-eks-production-deployment-guide)
- [Infrastructure Details](#-infrastructure-details)
- [Monitoring & Scaling](#-monitoring--scaling)
- [Troubleshooting](#-troubleshooting)

---

## 🏗️ Architecture Overview

### Microservices Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend                            │
│                      UI Service (Java)                      │
└───────────────┬─────────────────────────────────────────────┘
                │
        ┌───────┴───────┬──────────┬──────────┐
        │               │          │          │
┌───────▼─────┐  ┌──────▼───┐  ┌───▼──┐  ┌────▼────┐
│   Catalog   │  │   Cart   │  │Orders│  │Checkout │
│  (Golang)   │  │  (Java)  │  │(Java)│  │ (Node)  │
└──────┬──────┘  └────┬─────┘  └──┬───┘  └────┬────┘
       │              │           │           │
┌──────▼──────┐  ┌────▼───────┐   │      ┌────▼────┐
│   MySQL     │  │  DynamoDB  │   │      │  Redis  │
└─────────────┘  └────────────┘   │      └─────────┘
                             ┌────▼─────┐ ┌─────────┐
                             │PostgreSQL│ │RabbitMQ │
                             └──────────┘ └─────────┘
```

---

## 🚀 Deployment Strategies

### Helm Chart (EKS Production)

**Purpose**: Enterprise-grade multi-environment deployments with GitOps

**Features**:
- Umbrella chart pattern
- Environment-specific value files
- IRSA (IAM Roles for Service Accounts)
- Dynamic storage provisioning
- Production security standards

**Best For**: Multi-environment management (dev/staging/prod), AWS EKS deployments, GitOps workflows

---

## 🎯 Quick Start

### Prerequisites

```bash
# Required tools
- Docker 24+
- kubectl 1.28+
- Helm 3.14+
- AWS CLI (for EKS deployment)
- eksctl (for EKS cluster creation)
```

### K3s Local Development

```bash
# Install K3s
curl -sfL https://get.k3s.io | sh -

# Set kubeconfig
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Install metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Deploy application
cd retail-store-helm-chart
helm dependency update
helm upgrade --install retail-store . \
  -n retail-store-dev \
  -f values.yaml \
  -f values/k3s/values-dev-k3s.yaml \
  --create-namespace

# Access UI
# NodePort: http://<node-ip>:30080
```

---

## 🌩️ EKS Production Deployment Guide

This section provides a complete, step-by-step guide for deploying the retail store application on AWS EKS with production-grade configurations.

### Prerequisites

Before starting, ensure you have:

- ✅ AWS account with appropriate permissions
- ✅ AWS CLI installed and configured
- ✅ kubectl 1.28+ installed
- ✅ Helm 3.14+ installed
- ✅ eksctl installed (optional but recommended)

### Step 1: Create EKS Cluster

#### Option A: Using eksctl (Recommended)

Create an `eks.yaml` configuration file:

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

Deploy the cluster:

```bash
# Create cluster
eksctl create cluster --config-file=eks.yaml

# This takes 15-20 minutes
# Wait for completion

# Verify cluster access
kubectl get nodes
aws eks describe-cluster --name retail-store-cluster
```

#### Option B: Using AWS Console

1. Go to AWS Console → EKS → Clusters → Create cluster
2. Configure cluster settings:
   - Name: `retail-store-cluster`
   - Kubernetes version: 1.28
   - Cluster service role: Create new or select existing
3. Configure networking:
   - VPC: Create new or select existing
   - Subnets: Select at least 2 availability zones
   - Security groups: Create new
4. Create cluster (takes 15-20 minutes)
5. Add node group:
   - Instance type: t3.medium
   - Desired size: 3 nodes
   - IAM role: Create with EBS CSI permissions

### Step 2: Configure kubectl

```bash
# Update kubeconfig
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name retail-store-cluster

# Verify connection
kubectl get nodes
kubectl cluster-info
```

### Step 3: Install Required EKS Add-ons

#### 3.1 Install Metrics Server (Required for HPA)

```bash
# Install metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Wait for deployment
kubectl wait --for=condition=available deployment/metrics-server -n kube-system --timeout=300s

# Verify installation
kubectl get deployment metrics-server -n kube-system
kubectl top nodes  # Should return node metrics
```

#### 3.2 Install AWS EBS CSI Driver (Required for Persistent Volumes)

```bash
# Install EBS CSI driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.25"

# Verify installation
kubectl get pods -n kube-system | grep ebs-csi

# Expected output: 2 controller pods and daemonset pods on each node
```

#### 3.3 Configure EBS IAM Permissions

```bash
# Get node instance role name
NODE_ROLE=$(aws iam list-roles --query "Roles[?contains(RoleName,'nodegroup')].RoleName" --output text | head -1)

# Attach EBS CSI policy
aws iam attach-role-policy \
  --role-name $NODE_ROLE \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy

# Verify policy attachment
aws iam list-attached-role-policies --role-name $NODE_ROLE
```

### Step 4: Setup DynamoDB for Cart Service

#### 4.1 Create DynamoDB Table

```bash
# Create Items table
aws dynamodb create-table \
  --table-name Items \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1

# Verify table creation
aws dynamodb describe-table \
  --table-name Items \
  --region ap-south-1 \
  --query 'Table.[TableName,TableStatus,ItemCount]'

# Expected output: ["Items", "ACTIVE", 0]
```

#### 4.2 Enable OIDC Provider for IRSA

```bash
# Check if OIDC provider exists
OIDC_URL=$(aws eks describe-cluster \
  --name retail-store-cluster \
  --query "cluster.identity.oidc.issuer" \
  --output text)

echo "OIDC Provider URL: $OIDC_URL"

# If no OIDC provider, enable it
eksctl utils associate-iam-oidc-provider \
  --cluster retail-store-cluster \
  --approve

# Verify OIDC provider exists
aws iam list-open-id-connect-providers
```

#### 4.3 Create IAM Policy for DynamoDB Access

```bash
# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create policy document
cat > cart-dynamodb-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:ap-south-1:${ACCOUNT_ID}:table/Items"
    }
  ]
}
EOF

# Create IAM policy
aws iam create-policy \
  --policy-name cart-dynamodb-policy \
  --policy-document file://cart-dynamodb-policy.json

# Save policy ARN
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/cart-dynamodb-policy"
echo "Policy ARN: $POLICY_ARN"
```

#### 4.4 Create IAM Role with IRSA Trust Relationship

```bash
# Extract OIDC provider ID
OIDC_ID=$(echo $OIDC_URL | cut -d '/' -f 5)

# Create trust policy
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
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
    }
  ]
}
EOF

# Create IAM role
aws iam create-role \
  --role-name cart-dynamodb-role \
  --assume-role-policy-document file://trust-policy.json

# Attach DynamoDB policy to role
aws iam attach-role-policy \
  --role-name cart-dynamodb-role \
  --policy-arn $POLICY_ARN

# Verify role creation
aws iam get-role --role-name cart-dynamodb-role
```

### Step 5: Deploy Application with Helm

#### 5.1 Prepare Helm Chart

```bash
# Navigate to Helm chart directory
cd retail-store-helm-chart

# Update dependencies
helm dependency update

# This downloads all subchart dependencies
```

#### 5.2 Update Production Values

Edit `values/eks/values-prod-eks.yaml` and update the IAM role ARN:

```yaml
retail-store-cart:
  aws:
    authMethod: irsa
  serviceAccount:
    name: cart-sa
    roleArn: arn:aws:iam::YOUR_ACCOUNT_ID:role/cart-dynamodb-role  # Update this
```

Replace `YOUR_ACCOUNT_ID` with your actual AWS account ID.

#### 5.3 Validate Configuration (Dry Run)

```bash
# Set namespace context
kubectl config set-context --current --namespace=retail-store-prod

# Perform dry run
helm template retail-store . \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml \
  --namespace retail-store-prod

# Review the output for any errors
```

#### 5.4 Deploy to EKS

```bash
# Install application
helm upgrade --install retail-store . \
  -n retail-store-prod \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml \
  --create-namespace \
  --timeout 10m

# This creates:
# - Namespace: retail-store-prod
# - All microservices deployments
# - Database StatefulSets
# - Services and ConfigMaps
# - HPA autoscalers
# - IRSA ServiceAccount
```

### Step 6: Verify Deployment

```bash
# Check Helm release
helm list -n retail-store-prod

# Check all pods
kubectl get pods -n retail-store-prod

# Expected output: All pods in Running state
# NAME                           READY   STATUS    RESTARTS   AGE
# cart-deployment-xxx            1/1     Running   0          2m
# catalog-xxx                    1/1     Running   0          2m
# checkout-xxx                   1/1     Running   0          2m
# orders-xxx                     1/1     Running   0          2m
# ui-xxx                         1/1     Running   0          2m
# mysql-0                        1/1     Running   0          2m
# postgresql-0                   1/1     Running   0          2m
# redis-0                        1/1     Running   0          2m
# rabbitmq-0                     1/1     Running   0          2m

# Check services
kubectl get svc -n retail-store-prod

# Check HPA
kubectl get hpa -n retail-store-prod

# Check persistent volumes
kubectl get pvc -n retail-store-prod
kubectl get pv
```

### Step 7: Access the Application

#### Get LoadBalancer URL

```bash
# Get UI service external IP
kubectl get svc ui -n retail-store-prod

# Wait for EXTERNAL-IP to be assigned (not <pending>)
# This creates an AWS Classic Load Balancer

# Example output:
# NAME   TYPE           CLUSTER-IP      EXTERNAL-IP                          PORT(S)
# ui     LoadBalancer   10.100.xxx.xxx  a1234567890.ap-south-1.elb.amazonaws.com   80:xxxxx/TCP

# Access application
curl http://<EXTERNAL-IP>

# Or open in browser
echo "http://$(kubectl get svc ui -n retail-store-prod -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

### Step 8: Verify IRSA Configuration

```bash
# Check ServiceAccount annotation
kubectl describe sa cart-sa -n retail-store-prod

# Expected annotation:
# eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT_ID:role/cart-dynamodb-role

# Check pod environment variables
kubectl exec -it deployment/cart-deployment -n retail-store-prod -- env | grep AWS

# Expected variables:
# AWS_ROLE_ARN=arn:aws:iam::ACCOUNT_ID:role/cart-dynamodb-role
# AWS_WEB_IDENTITY_TOKEN_FILE=/var/run/secrets/eks.amazonaws.com/serviceaccount/token
# AWS_REGION=ap-south-1

# Check cart logs for successful DynamoDB connection
kubectl logs deployment/cart-deployment -n retail-store-prod | tail -20

# No AccessDenied errors = successful IRSA setup
```

### Step 9: Test Application Functionality

```bash
# Test catalog service
kubectl exec -it deployment/cart-deployment -n retail-store-prod -- \
  curl http://catalog:8080/catalogue

# Test cart service (should connect to DynamoDB)
kubectl exec -it deployment/ui -n retail-store-prod -- \
  curl http://cart:8080/cart/test-user

# Check database connectivity
# MySQL
kubectl exec -it mysql-0 -n retail-store-prod -- \
  mysql -u catalog_user -ppassword -e "SHOW DATABASES;"

# PostgreSQL
kubectl exec -it postgresql-0 -n retail-store-prod -- \
  psql -U postgres_user -d postgres -c "\l"
```

### Step 10: Enable Auto-Scaling

The HPA is already configured in the Helm chart. Monitor scaling:

```bash
# Watch HPA status
kubectl get hpa -n retail-store-prod -w

# Generate load for testing (optional)
kubectl run -it --rm load-generator \
  --image=busybox \
  -n retail-store-prod \
  -- /bin/sh

# Inside the pod
while true; do wget -q -O- http://ui; done
```

### Step 11: Monitor Application

```bash
# View resource usage
kubectl top nodes
kubectl top pods -n retail-store-prod

# Check logs
kubectl logs -f deployment/cart-deployment -n retail-store-prod
kubectl logs -f deployment/ui -n retail-store-prod

# View events
kubectl get events -n retail-store-prod --sort-by='.lastTimestamp'

# Check service health
kubectl exec -it deployment/ui -n retail-store-prod -- \
  curl http://catalog:8080/health
```

---

## 📊 Monitoring & Scaling

### Horizontal Pod Autoscaling

HPA is pre-configured in the Helm chart for all services:

```yaml
hpa:
  minReplicas: 1
  maxReplicas: 3
  averageUtilization: 70
```

Monitor HPA:

```bash
# Watch HPA status
kubectl get hpa -n retail-store-prod -w

# Detailed HPA info
kubectl describe hpa cart-hpa -n retail-store-prod
```

### Scaling Databases

For production, consider:

- **MySQL**: Use Amazon RDS Multi-AZ
- **PostgreSQL**: Use Amazon RDS
- **Redis**: Use Amazon ElastiCache
- **RabbitMQ**: Use Amazon MQ

---

## 🧹 Cleanup

### Uninstall Application Only

```bash
# Uninstall Helm release
helm uninstall retail-store -n retail-store-prod

# Delete namespace
kubectl delete namespace retail-store-prod

# Persistent volumes are automatically deleted (ReclaimPolicy: Delete)
```

### Full Cleanup (Including AWS Resources)

```bash
# Delete application
helm uninstall retail-store -n retail-store-prod
kubectl delete namespace retail-store-prod

# Delete DynamoDB table
aws dynamodb delete-table \
  --table-name Items \
  --region ap-south-1

# Delete IAM resources
aws iam detach-role-policy \
  --role-name cart-dynamodb-role \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/cart-dynamodb-policy

aws iam delete-role --role-name cart-dynamodb-role

aws iam delete-policy \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/cart-dynamodb-policy

# Delete EKS cluster
eksctl delete cluster --name retail-store-cluster
```

---

## 🐛 Troubleshooting

### EKS-Specific Issues

#### Pod CrashLoopBackOff

```bash
# Check logs
kubectl logs <pod-name> -n retail-store-prod --previous

# Describe pod
kubectl describe pod <pod-name> -n retail-store-prod

# Common causes:
# - Missing EBS CSI driver
# - Incorrect IAM role configuration
# - DynamoDB table doesn't exist
# - Resource limits too low
```

#### Persistent Volume Issues

```bash
# Check storage class
kubectl get sc

# Check PVCs
kubectl get pvc -n retail-store-prod

# Describe PVC
kubectl describe pvc mysql-data-mysql-0 -n retail-store-prod

# Common issues:
# - EBS CSI driver not installed
# - IAM permissions missing
# - Storage class misconfigured
```

#### LoadBalancer Service Pending

```bash
# Check service
kubectl describe svc ui -n retail-store-prod

# Common issues:
# - Insufficient subnet IPs
# - Security group restrictions
# - AWS Load Balancer Controller not configured
```

#### IRSA Authentication Failures

```bash
# Verify OIDC provider
aws iam list-open-id-connect-providers

# Check IAM role
aws iam get-role --role-name cart-dynamodb-role

# Verify ServiceAccount
kubectl get sa cart-sa -n retail-store-prod -o yaml

# Check pod logs
kubectl logs deployment/cart-deployment -n retail-store-prod

# Common issues:
# - OIDC provider not enabled
# - Trust relationship incorrect
# - ServiceAccount annotation missing
```

#### DynamoDB Connection Issues

```bash
# Verify table exists
aws dynamodb describe-table --table-name Items --region ap-south-1

# Test from pod
kubectl exec -it deployment/cart-deployment -n retail-store-prod -- env | grep AWS

# Common issues:
# - Table doesn't exist
# - Wrong region
# - IAM policy incorrect
# - Static credentials present (conflicts with IRSA)
```

### Debug Commands

```bash
# Check cluster health
kubectl get nodes
kubectl cluster-info

# Check EBS CSI driver
kubectl get pods -n kube-system | grep ebs-csi

# View all resources
kubectl get all -n retail-store-prod

# Check resource usage
kubectl top nodes
kubectl top pods -n retail-store-prod

# Interactive shell
kubectl exec -it deployment/cart-deployment -n retail-store-prod -- /bin/sh

# Port forward for debugging
kubectl port-forward svc/ui 8080:80 -n retail-store-prod
```

---

## 📚 Additional Resources

### Documentation
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [IRSA Setup Guide](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)

### Architecture Diagrams
See `assets/` folder for detailed architecture diagrams

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test changes thoroughly
4. Submit a pull request

---

<div align="center">

**⭐ Star this repo if you find it helpful!**

Made with ❤️ for the DevOps community

</div>