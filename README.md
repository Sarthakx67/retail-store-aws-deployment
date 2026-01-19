# 🛒 AWS Retail Store - Cloud-Native Microservices Deployment

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)

> **Production-grade microservices deployment showcasing multiple infrastructure patterns, from manual EC2 provisioning to automated Kubernetes orchestration with Helm.**

This repository demonstrates a complete DevOps journey for deploying a retail store application using modern cloud-native practices. It includes four distinct deployment strategies, each solving different operational challenges.

---

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Deployment Strategies](#-deployment-strategies)
- [Technology Stack](#-technology-stack)
- [Microservices Components](#-microservices-components)
- [Quick Start](#-quick-start)
- [Deployment Guides](#-deployment-guides)
- [Infrastructure Details](#-infrastructure-details)
- [Monitoring & Scaling](#-monitoring--scaling)
- [Security & Best Practices](#-security--best-practices)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

---

## 🏗️ Architecture Overview

### Microservices Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend                             │
│                      UI Service (Java)                       │
└───────────────┬─────────────────────────────────────────────┘
                │
        ┌───────┴───────┬──────────┬──────────┐
        │               │          │          │
┌───────▼─────┐  ┌─────▼────┐  ┌─▼────┐  ┌──▼──────┐
│   Catalog   │  │   Cart   │  │Orders│  │Checkout │
│  (Golang)   │  │  (Java)  │  │(Java)│  │ (Node)  │
└──────┬──────┘  └────┬─────┘  └──┬───┘  └────┬────┘
       │              │            │           │
┌──────▼──────┐  ┌───▼────────┐  │      ┌────▼────┐
│   MySQL     │  │  DynamoDB  │  │      │  Redis  │
└─────────────┘  └────────────┘  │      └─────────┘
                            ┌────▼────┐  ┌─────────┐
                            │PostgreSQL│  │RabbitMQ│
                            └─────────┘  └─────────┘
```

### Infrastructure Patterns

| Pattern | Use Case | Complexity |
|---------|----------|------------|
| **EC2 Manual** | Learning, legacy migration | ⭐ |
| **Docker Compose** | Local development, testing | ⭐⭐ |
| **Kubernetes (K3s)** | Single-node prod, edge computing | ⭐⭐⭐ |
| **Helm + EKS** | Enterprise production, multi-env | ⭐⭐⭐⭐ |

---

## 🚀 Deployment Strategies

### 1️⃣ Manual EC2 Deployment (Terraform)

**Purpose**: Infrastructure as Code foundation with manual service orchestration

**Components**:
- VPC with public/private subnets
- EC2 instances with user-data scripts
- Route53 DNS management
- Security groups with least-privilege rules
- SSM Parameter Store for configuration sharing

**Best For**: 
- Learning IaC fundamentals
- Migrating monoliths to microservices
- Cost-conscious environments

[→ View EC2 Deployment Guide](#ec2-deployment-with-terraform)

---

### 2️⃣ Docker Compose

**Purpose**: Rapid local development and integration testing

**Features**:
- Single-command deployment
- Isolated network environment
- Service dependency management
- Instant environment setup

**Best For**:
- Development environments
- CI/CD testing stages
- Proof of concepts

[→ View Docker Compose Guide](#docker-compose-deployment)

---

### 3️⃣ Kubernetes Deployment (K3s)

**Purpose**: Production-ready orchestration with cloud-agnostic patterns

**Features**:
- StatefulSets for databases
- ConfigMaps and Secrets management
- Horizontal Pod Autoscaling (HPA)
- Service discovery via DNS
- Persistent volume claims

**Best For**:
- On-premises Kubernetes
- Edge computing
- Single-node production

[→ View Kubernetes Guide](#kubernetes-deployment)

---

### 4️⃣ Helm Chart (EKS Ready)

**Purpose**: Enterprise-grade multi-environment deployments with GitOps

**Features**:
- Umbrella chart pattern
- Environment-specific value files
- IRSA (IAM Roles for Service Accounts)
- Dynamic storage provisioning
- Production security standards

**Best For**:
- Multi-environment management (dev/staging/prod)
- AWS EKS deployments
- GitOps workflows (ArgoCD/Flux)

[→ View Helm Deployment Guide](#helm-chart-deployment)

---

## 🛠️ Technology Stack

### Languages & Frameworks

| Service | Language | Framework | Purpose |
|---------|----------|-----------|---------|
| UI | Java 21 | Spring Boot | Frontend application |
| Cart | Java 21 | Spring Boot | Shopping cart management |
| Catalog | Golang 1.25 | Native | Product catalog |
| Orders | Java 21 | Spring Boot | Order processing |
| Checkout | Node.js 20 | NestJS | Payment processing |

### Infrastructure

| Component | Technology | Version |
|-----------|------------|---------|
| Container Runtime | Docker | 24+ |
| Orchestration | Kubernetes | 1.28+ |
| Package Manager | Helm | 3.14+ |
| IaC | Terraform | 1.7+ |
| Cloud Provider | AWS | N/A |
| Lightweight K8s | K3s | 1.28+ |

### Databases & Messaging

| Service | Technology | Usage |
|---------|------------|-------|
| Catalog | MySQL 8 | Product data |
| Cart | DynamoDB | Session data |
| Orders | PostgreSQL 15 | Order records |
| Checkout | Redis 7 | Caching |
| Messaging | RabbitMQ 3 | Event streaming |

---

## 🧩 Microservices Components

### UI Service
- **Port**: 8080
- **Role**: User-facing web interface
- **Dependencies**: All backend services
- **Environment Variables**:
  ```bash
  RETAIL_UI_ENDPOINTS_CATALOG=http://catalog:8080
  RETAIL_UI_ENDPOINTS_CARTS=http://cart:8080
  RETAIL_UI_ENDPOINTS_ORDERS=http://orders:8080
  RETAIL_UI_ENDPOINTS_CHECKOUT=http://checkout:8080
  ```

### Catalog Service
- **Port**: 8080
- **Technology**: Golang with MySQL
- **Features**: Product browsing, search, filtering
- **Build**: CGO-enabled for SQLite compatibility

### Cart Service
- **Port**: 8080
- **Technology**: Java with DynamoDB
- **Features**: Shopping cart CRUD operations
- **Storage**: 
  - Local: DynamoDB Local
  - Production: AWS DynamoDB (IRSA)

### Orders Service
- **Port**: 8080
- **Technology**: Java with PostgreSQL & RabbitMQ
- **Features**: Order creation, status tracking
- **Messaging**: Publishes order events

### Checkout Service
- **Port**: 8080
- **Technology**: Node.js with Redis
- **Features**: Payment processing, order finalization
- **Memory**: Requires `--max-old-space-size=768`

---

## 🎯 Quick Start

### Prerequisites

```bash
# Required tools
- Docker 24+
- kubectl 1.28+
- Helm 3.14+
- Terraform 1.7+ (for EC2 deployment)
- AWS CLI (for EKS deployment)
```

### Local Development (Docker Compose)

```bash
# Clone repository
git clone <repository-url>
cd src

# Start all services
docker-compose up -d

# Access UI
open http://localhost:80
```

### K3s Deployment

```bash
# Install K3s
curl -sfL https://get.k3s.io | sh -

# Set kubeconfig
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Install metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Deploy application
kubectl apply -f kubernetes-deployment/
```

### Helm Deployment (Production)

```bash
# Update dependencies
cd retail-store-helm-chart
helm dependency update

# Deploy to K3s (local)
helm upgrade --install retail-store . \
  -n retail-store-dev \
  -f values.yaml \
  -f values/k3s/values-dev-k3s.yaml \
  --create-namespace

# Deploy to EKS (production)
helm upgrade --install retail-store . \
  -n retail-store-prod \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml \
  --create-namespace
```

---

## 📖 Deployment Guides

### EC2 Deployment with Terraform

#### Architecture
- **VPC**: `10.0.0.0/16`
- **Public Subnet**: `10.0.1.0/24` (UI, VPN)
- **Private Subnet**: `10.0.2.0/24` (Backend services)
- **DNS**: Route53 private hosted zone

#### Deployment Order

```bash
# 1. VPC Infrastructure
cd aws-ec2-manual-terraform-deployment/vpc
terraform init
terraform apply

# 2. Security Groups
cd ../firewall
terraform apply

# 3. VPN Bastion
cd ../vpn
terraform apply

# 4. Backend Services (in parallel)
cd ../catalog && terraform apply &
cd ../cart && terraform apply &
cd ../orders && terraform apply &
cd ../checkout && terraform apply &
wait

# 5. Frontend
cd ../ui
terraform apply
```

#### Configuration Management

All resources share configuration via SSM Parameter Store:

```hcl
# Example parameter usage
data "aws_ssm_parameter" "vpc_id" {
  name = "/retail_store_aws/vpc_id"
}
```

#### Security Features
- Private subnet for backend services
- Bastion host (VPN) for SSH access
- Security group chaining
- Route53 internal DNS
- No public IPs on backend services

---

### Docker Compose Deployment

#### Network Architecture

```yaml
networks:
  retail-net:
    driver: bridge
```

All services communicate via internal DNS names.

#### Service Dependencies

```yaml
ui:
  depends_on:
    - cart
    - catalog
    - checkout
    - orders
```

Ensures backend services start before frontend.

#### Usage

```bash
# Start
docker-compose up -d

# View logs
docker-compose logs -f [service]

# Stop
docker-compose down

# Rebuild after changes
docker-compose up -d --build
```

---

### Kubernetes Deployment

#### Namespace Structure

```bash
kubectl create namespace retail-store
kubectl config set-context --current --namespace=retail-store
```

#### Resource Organization

```
kubernetes-deployment/
├── namespace.yaml
├── ui.yaml
├── cart.yaml
├── catalog.yaml
├── orders.yaml
├── checkout.yaml
├── mysql.yaml
├── dynamodb.yaml
├── postgresql.yaml
├── rabbitmq.yaml
└── redis.yaml
```

#### Deployment

```bash
# Create namespace
kubectl apply -f namespace.yaml

# Deploy databases (order matters)
kubectl apply -f mysql.yaml
kubectl apply -f postgresql.yaml
kubectl apply -f redis.yaml
kubectl apply -f rabbitmq.yaml
kubectl apply -f dynamodb.yaml

# Wait for databases
kubectl wait --for=condition=ready pod -l tier=db --timeout=300s

# Deploy services
kubectl apply -f catalog.yaml
kubectl apply -f cart.yaml
kubectl apply -f orders.yaml
kubectl apply -f checkout.yaml
kubectl apply -f ui.yaml
```

#### Verification

```bash
# Check pods
kubectl get pods

# Check services
kubectl get svc

# Check HPA
kubectl get hpa

# View logs
kubectl logs -f deployment/ui-deployment
```

#### Access UI

```bash
# NodePort (K3s)
http://<node-ip>:30080
```

---

### Helm Chart Deployment

#### Chart Structure

```
retail-store-helm-chart/
├── Chart.yaml              # Umbrella chart
├── values.yaml             # Base values
├── values/
│   ├── k3s/
│   │   └── values-dev-k3s.yaml
│   └── eks/
│       └── values-prod-eks.yaml
└── charts/                 # Subcharts
    ├── cart/
    ├── catalog/
    ├── checkout/
    ├── orders/
    ├── ui/
    ├── mysql/
    ├── postgresql/
    ├── redis/
    ├── rabbitmq/
    └── dynamodb/
```

#### Environment Strategy

**Base Values** (`values.yaml`):
- Environment-agnostic defaults
- All services enabled

**K3s Overrides** (`values/k3s/values-dev-k3s.yaml`):
- DynamoDB local enabled
- Static AWS credentials
- NodePort for UI
- `local-path` storage class

**EKS Overrides** (`values/eks/values-prod-eks.yaml`):
- DynamoDB local disabled
- IRSA for AWS access
- LoadBalancer for UI
- `ebs-sc` storage class
- Production resource limits

#### Key Features

##### 1. Horizontal Pod Autoscaling

```yaml
hpa:
  minReplicas: 1
  maxReplicas: 3
  averageUtilization: 70
```

##### 2. Resource Management

```yaml
resources:
  requests:
    cpu: 200m
    memory: 512Mi
  limits:
    cpu: 500m
    memory: 1Gi
```

##### 3. AWS Authentication Methods

**Local Development** (K3s):
```yaml
aws:
  authMethod: static
secrets:
  accessKeyId: local
  secretAccessKey: local
configmap:
  endpoint: http://dynamodb:8000
```

**Production** (EKS):
```yaml
aws:
  authMethod: irsa
serviceAccount:
  name: cart-sa
  roleArn: arn:aws:iam::ACCOUNT_ID:role/cart-dynamodb-role
```

##### 4. Storage Classes

| Environment | Storage Class | Provider |
|-------------|---------------|----------|
| K3s | `local-path` | Local storage |
| EKS | `ebs-sc` | AWS EBS |

#### Deployment Commands

```bash
# Prepare dependencies
helm dependency update

# Dry run (validate)
helm template retail-store . \
  -f values.yaml \
  -f values/k3s/values-dev-k3s.yaml

# Install (K3s)
helm upgrade --install retail-store . \
  -n retail-store-dev \
  -f values.yaml \
  -f values/k3s/values-dev-k3s.yaml \
  --create-namespace

# Install (EKS)
helm upgrade --install retail-store . \
  -n retail-store-prod \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml \
  --create-namespace

# Check deployment
helm list -n retail-store-dev
kubectl get all -n retail-store-dev

# Uninstall
helm uninstall retail-store -n retail-store-dev
```

---

## 🏗️ Infrastructure Details

### AWS EKS IRSA Setup

#### Prerequisites

1. **EKS Cluster** with OIDC provider enabled
2. **DynamoDB Table** created (name: `Items`)
3. **IAM Permissions** to create roles and policies

#### Step-by-Step Setup

##### 1. Create IAM Policy

```json
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
      "Resource": "arn:aws:dynamodb:REGION:ACCOUNT_ID:table/Items"
    }
  ]
}
```

##### 2. Create IAM Role with Trust Relationship

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.REGION.amazonaws.com/id/OIDC_ID"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.REGION.amazonaws.com/id/OIDC_ID:sub": "system:serviceaccount:retail-store-prod:cart-sa"
        }
      }
    }
  ]
}
```

##### 3. Update Helm Values

```yaml
retail-store-cart:
  aws:
    authMethod: irsa
  serviceAccount:
    name: cart-sa
    roleArn: arn:aws:iam::ACCOUNT_ID:role/cart-dynamodb-role
```

##### 4. Verification

```bash
# Check ServiceAccount annotation
kubectl describe sa cart-sa -n retail-store-prod

# Check pod environment
kubectl exec -it deployment/cart-deployment -n retail-store-prod -- env | grep AWS

# Check application logs
kubectl logs deployment/cart-deployment -n retail-store-prod
```

---

### Storage Management

#### K3s (Local Path Provisioner)

```yaml
persistence:
  storageClass: local-path
  size: 5Gi
```

- Storage located on node filesystem
- No replication
- Suitable for development

#### EKS (AWS EBS)

```yaml
persistence:
  storageClass: ebs-sc
  size: 5Gi
```

**Create EBS Storage Class**:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "true"
volumeBindingMode: WaitForFirstConsumer
```

#### StatefulSet Volume Behavior

- Each pod receives its own PVC
- Volumes persist across pod restarts
- Data NOT shared between replicas
- Database replication handled at application level

---

## 📊 Monitoring & Scaling

### Horizontal Pod Autoscaling

#### Metrics Server Installation

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

#### Verify Metrics

```bash
kubectl top nodes
kubectl top pods -n retail-store
```

#### HPA Configuration

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: cart-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: cart-deployment
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

#### Monitor Scaling

```bash
# Watch HPA
kubectl get hpa -n retail-store -w

# Generate load
kubectl run -it --rm load-generator --image=busybox /bin/sh
while true; do wget -q -O- http://cart:8080/health; done
```

---

## 🔒 Security & Best Practices

### Container Security

#### Multi-Stage Builds

```dockerfile
FROM maven:3.9.9-amazoncorretto-21 AS build
WORKDIR /app
COPY pom.xml .
RUN ./mvnw -B dependency:go-offline
COPY src ./src
RUN ./mvnw -B package -DskipTests

FROM amazoncorretto:21
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
CMD ["java", "-jar", "app.jar"]
```

**Benefits**:
- Smaller final images
- No build tools in production
- Faster deployments
- Reduced attack surface

#### Build Optimization

- Dependency caching via layer separation
- `.dockerignore` to exclude unnecessary files
- Non-root users (recommended)

### Kubernetes Security

#### Secrets Management

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
data:
  MYSQL_PASSWORD: <base64-encoded>
```

**Best Practices**:
- Use external secrets management (AWS Secrets Manager, Vault)
- Rotate credentials regularly
- Never commit secrets to Git
- Use RBAC to limit secret access

#### Network Policies (Recommended)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      component: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          component: frontend
```

#### Resource Quotas

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
```

### AWS Security

#### IAM Least Privilege

- Use IRSA instead of static credentials
- Scope policies to specific resources
- Enable CloudTrail logging
- Regular security audits

#### VPC Configuration

- Private subnets for backend services
- NAT Gateway for outbound traffic
- Security groups with specific CIDR blocks
- VPC Flow Logs enabled

---

## 🐛 Troubleshooting

### Common Issues

#### Pod CrashLoopBackOff

```bash
# Check logs
kubectl logs <pod-name> -n retail-store --previous

# Describe pod
kubectl describe pod <pod-name> -n retail-store

# Common causes:
# - Missing environment variables
# - Database connection failures
# - Resource limits too low
# - Image pull errors
```

#### Service Not Accessible

```bash
# Check service endpoints
kubectl get endpoints -n retail-store

# Verify pod labels match service selector
kubectl get pods --show-labels -n retail-store

# Test internal connectivity
kubectl run -it --rm debug --image=nicolaka/netshoot -- bash
curl http://catalog:8080/health
```

#### Database Connection Issues

```bash
# Check database pod status
kubectl get pods -l tier=db -n retail-store

# Check persistent volumes
kubectl get pvc -n retail-store

# Verify secrets
kubectl get secret mysql-secret -o yaml -n retail-store
```

#### HPA Not Scaling

```bash
# Verify metrics server
kubectl get deployment metrics-server -n kube-system

# Check HPA status
kubectl describe hpa cart-hpa -n retail-store

# Common issues:
# - Metrics server not installed
# - Resource requests not defined
# - Insufficient cluster resources
```

#### DynamoDB Connection (EKS)

```bash
# Verify IRSA setup
kubectl describe sa cart-sa -n retail-store-prod

# Check pod AWS credentials
kubectl exec -it deployment/cart-deployment -n retail-store-prod -- env | grep AWS

# Common issues:
# - ServiceAccount not annotated
# - IAM role trust policy incorrect
# - OIDC provider not enabled
# - DynamoDB table doesn't exist
```

### Debug Commands

```bash
# Interactive shell in pod
kubectl exec -it deployment/cart-deployment -n retail-store -- /bin/sh

# Port forward for local access
kubectl port-forward svc/ui 8080:8080 -n retail-store

# View all resources
kubectl get all -n retail-store

# Check resource usage
kubectl top pods -n retail-store --sort-by=cpu

# Export logs
kubectl logs deployment/cart-deployment -n retail-store > cart.log
```

---

## 🧪 Testing

### Health Checks

```bash
# Individual services
curl http://<service-ip>:8080/health

# From within cluster
kubectl run -it --rm curl --image=curlimages/curl -- sh
curl http://catalog:8080/health
curl http://cart:8080/health
curl http://orders:8080/health
curl http://checkout:8080/health
```

### Load Testing

```bash
# Install hey
go install github.com/rakyll/hey@latest

# Run load test
hey -z 60s -c 10 http://<ui-ip>:8080
```

---

## 📚 Additional Resources

### Documentation
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Helm Chart Guide](https://helm.sh/docs/chart_template_guide/)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Related Projects
- [Original Retail Store App](https://github.com/aws-containers/retail-store-sample-app)
- [K3s Documentation](https://docs.k3s.io/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/improvement`)
5. Open a Pull Request

### Code Standards
- Use meaningful commit messages
- Add comments to complex logic
- Update documentation for new features
- Test all changes locally before submitting

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your Profile](https://linkedin.com/in/yourprofile)
- Email: your.email@example.com

---

## 🙏 Acknowledgments

- AWS Containers team for the original retail store sample app
- Kubernetes community for excellent documentation
- Helm community for chart best practices
- All contributors who help improve this project

---

<div align="center">

**⭐ Star this repo if you find it helpful!**

Made with ❤️ for the DevOps community

</div>