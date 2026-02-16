# AWS Retail Store: Production-Grade Microservices Platform

> Enterprise microservices deployment on AWS EKS with automated CI/CD, IRSA security, and production-grade observability

---

## 🎯 What This Demonstrates

This project showcases **production-ready DevOps practices** for deploying a polyglot microservices application:

- **Infrastructure as Code** – Full Terraform automation (VPC, EKS, IAM, Security Groups)
- **Container Orchestration** – Kubernetes on AWS EKS with Helm umbrella charts
- **CI/CD Automation** – Jenkins pipelines with automated image builds and deployments
- **Zero-Trust Security** – IAM Roles for Service Accounts (IRSA) - no hardcoded credentials
- **Production Monitoring** – Prometheus + Grafana with custom service dashboards
- **Autoscaling** – Horizontal Pod Autoscaling based on CPU/memory metrics

---

## 🏗️ Architecture Overview

**Multi-tier microservices architecture across 3 Availability Zones in AWS ap-south-1**

### Key Components:
- **Frontend**: Java Spring Boot UI
- **Backend Services**: Cart (Java), Catalog (Go), Orders (Java), Checkout (Node.js)
- **Data Stores**: MySQL, PostgreSQL, Redis, RabbitMQ, DynamoDB
- **Infrastructure**: Custom VPC with private subnets, EKS cluster, Application Load Balancer

### Security Implementation:
- EKS worker nodes in **private subnets** (no direct internet exposure)
- **IRSA** for Cart service → DynamoDB access via temporary credentials
- Security Groups with least-privilege access
- Secrets management via Kubernetes Secrets

---

## 💼 Core DevOps Skills Demonstrated

### 1. Infrastructure Automation
- Terraform modules for VPC, EKS, IAM, Security Groups
- State management and modular design
- AWS SSM Parameter Store for cross-stack references
- Dynamic provisioning with AWS EBS CSI Driver

### 2. Container & Orchestration
- Multi-stage Docker builds for optimized images
- Helm umbrella charts with environment-specific values
- StatefulSets for databases with persistent volumes
- HPA configuration with startup/liveness/readiness probes

### 3. CI/CD Pipeline
- Jenkins shared libraries for reusable pipeline code
- Automated version detection (Maven, Go, Node.js)
- Docker image builds and push to registry
- Automated Helm deployments with rollout verification

### 4. Security & IAM
- IRSA implementation (no AWS access keys in pods)
- OIDC provider integration for EKS
- IAM policy design with least-privilege access
- ServiceAccount annotations for role assumption

### 5. Observability
- Prometheus ServiceMonitors for metrics collection
- Custom Grafana dashboards per service
- Application instrumentation (/actuator/prometheus, /metrics)
- Request rate, error rate, latency (P95), CPU throttling monitoring

---

## 🚀 Quick Deployment

### Prerequisites
- AWS account with EKS access
- kubectl and Helm CLI installed
- AWS CLI configured

### Deploy to EKS Production
```bash
# 1. Create infrastructure
cd terraform/
terraform init
terraform apply

# 2. Install metrics server (required for HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 3. Deploy application
cd retail-store-helm-chart/
helm dependency update
helm upgrade --install retail-store . \
  -n retail-store-prod \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml \
  --create-namespace

# 4. Verify deployment
kubectl get pods -n retail-store-prod
kubectl top nodes
kubectl get hpa
```

---

## 📊 Monitoring & Observability

**Prometheus + Grafana stack** monitors:
- HTTP request rates and error rates (5xx)
- P95/P99 latency percentiles
- JVM memory and CPU usage
- Pod restarts and resource throttling

Access Grafana:
```bash
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
# Username: admin
# Password: kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d
```

---

## 🔄 CI/CD Pipeline Flow
```
Developer Push → GitHub
      ↓
Jenkins Detects Change
      ↓
Version Detection (Maven/Go/Node)
      ↓
Docker Build (Multi-stage)
      ↓
Push to Registry (Docker Hub/ECR)
      ↓
Helm Upgrade Deployment
      ↓
Rollout Verification
```

**Jenkins Shared Library** handles:
- Automatic version extraction from source files
- Conditional Docker builds based on service type
- Environment-specific Helm value selection
- Deployment health checks

---

## 🛠️ Technology Stack

| Layer | Technology |
|-------|------------|
| **Cloud** | AWS (EKS, ECR, DynamoDB, VPC, IAM, ALB) |
| **IaC** | Terraform (modular structure) |
| **Orchestration** | Kubernetes 1.28+ with Helm 3 |
| **CI/CD** | Jenkins with Groovy pipelines |
| **Monitoring** | Prometheus + Grafana |
| **Languages** | Java (Spring Boot), Go (Gin), Node.js (NestJS) |
| **Databases** | MySQL 8, PostgreSQL 15, Redis 7, RabbitMQ 3 |

---

## 📂 Repository Structure
```
├── terraform/                      # Infrastructure as Code
│   ├── vpc/                       # VPC, Subnets, IGW
│   ├── firewall/                  # Security Groups
│   ├── cart/, catalog/, ui/       # EC2 service modules
│   └── vpn/                       # Bastion host
│
├── retail-store-helm-chart/        # Kubernetes deployment
│   ├── Chart.yaml                 # Umbrella chart
│   ├── values/
│   │   ├── k3s/                   # Local development
│   │   └── eks/                   # Production AWS
│   └── charts/                    # Service subcharts
│
└── retail-store-Jenkins-shared-library/
    ├── detectVersion.groovy       # Auto version detection
    ├── dockerBuildPush.groovy     # Container builds
    └── deployK8s.groovy           # Helm deployments
```

---

## 🎓 Key Learning Outcomes

This project demonstrates:

1. **Production mindset** – Private subnets, IRSA, no hardcoded secrets
2. **Scalability** – HPA, StatefulSets with PVCs, multi-AZ deployment
3. **Automation** – Terraform + Jenkins + Helm = zero manual steps
4. **Troubleshooting** – Health probes, metrics, logs, resource monitoring
5. **GitOps readiness** – Environment-specific values, declarative configuration

---

## 👤 About Me

**Sarthak Singh** – 2nd Year Computer Engineering Student  
Aspiring DevOps Engineer focused on **Secure, Scalable, Observable** systems

📧 sarthak.devops@email.com  
🔗 [LinkedIn](https://www.linkedin.com/in/sarthak-singh-a0aa62322) | [GitHub](https://github.com/Sarthakx67)

---

## 📄 License

This project is open-source and available for educational purposes.