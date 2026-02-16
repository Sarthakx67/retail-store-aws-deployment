# 🚀 AWS Retail Store – Production-Grade Microservices Platform

> Secure • Scalable • Observable • Fully Automated  
> Built with AWS EKS, Terraform, Kubernetes, Helm & Jenkins

---

# 🌐 Live Application Preview

## 🖥️ Customer UI

<p align="center">
  <img src="./assets/01-ui.png" width="900"/>
</p>

---

## 🛍️ Product Catalog

<p align="center">
  <img src="./assets/02-catalog.png" width="900"/>
</p>

---

## 🛒 Shopping Cart

<p align="center">
  <img src="./assets/03-cart.png" width="900"/>
</p>

---

## 💳 Checkout Flow

<p align="center">
  <img src="./assets/04-checkout-1.png" width="900"/>
  <br/><br/>
  <img src="./assets/05-checkout-2.png" width="900"/>
  <br/><br/>
  <img src="./assets/06-checkout-3.png" width="900"/>
</p>

---

## 📦 Orders Management

<p align="center">
  <img src="./assets/07-orders.png" width="900"/>
</p>

---

# 🏗️ Architecture Overview

## 🔹 Application Services

<p align="center">
  <img src="./assets/application-services.png" width="900"/>
</p>

- UI (Spring Boot)
- Cart (Spring Boot + DynamoDB)
- Catalog (Go + MySQL)
- Orders (Spring Boot + PostgreSQL)
- Checkout (Node.js + Redis)

---

## 🔹 EKS Worker Nodes (Private Subnets)

<p align="center">
  <img src="./assets/eks-nodes-workstation.png" width="900"/>
</p>

✔ Private subnet deployment  
✔ No direct internet exposure  
✔ IAM Roles for Service Accounts (IRSA)

---

## 🔹 Kubernetes Resource Status

<p align="center">
  <img src="./assets/status-pod-svc-pv-pvc.png" width="900"/>
</p>

✔ Pods  
✔ Services  
✔ Persistent Volumes  
✔ Persistent Volume Claims  

---

## 🔹 Persistent Storage (EBS CSI)

<p align="center">
  <img src="./assets/volumes.png" width="900"/>
</p>

✔ Dynamic EBS provisioning  
✔ StatefulSets for databases  
✔ Persistent storage lifecycle management  

---

## 🔹 PostgreSQL Orders Database

<p align="center">
  <img src="./assets/postgresql-orders.png" width="900"/>
</p>

✔ Dedicated Orders DB  
✔ Stateful workload  
✔ Persistent volume backed  

---

# ⚙️ Infrastructure as Code (Terraform)

<p align="center">
  <img src="./assets/aws-ec2-manual-terraform-deployment.png" width="900"/>
</p>

### Key Highlights

- Modular Terraform structure
- Remote state management
- Parameterized configuration via SSM
- Zero-downtime updates
- Multi-AZ VPC architecture

---

# 🔄 CI/CD Automation (Jenkins)

<p align="center">
  <img src="./assets/retail-store-Jenkins-shared-library.png" width="900"/>
</p>

### Pipeline Features

- Automated version detection
- Multi-stage Docker builds
- Image tagging & registry push
- Helm-based Kubernetes deployment
- Shared pipeline libraries

---

# 📦 Helm Deployment Structure

<p align="center">
  <img src="./assets/retail-store-helm-chart.png" width="900"/>
</p>

### Helm Features

- Umbrella chart architecture
- Environment-based values (k3s vs EKS)
- Horizontal Pod Autoscaling (HPA)
- Liveness, Readiness, Startup probes
- ConfigMap & Secret management

---

# 📊 Observability & Monitoring

✔ Prometheus (metrics collection)  
✔ Grafana (dashboards)  
✔ Custom metrics (RPS, error rate, P95 latency)  
✔ Resource monitoring (CPU, memory, restarts)  
✔ ServiceMonitor auto-discovery  

---

# 🔐 Security Best Practices Implemented

- IRSA (No AWS keys in code)
- OIDC integration between EKS and IAM
- Least privilege IAM policies
- Private worker nodes
- Security groups with minimal ingress rules

---

# 📈 Performance Improvements

| Metric | Before | After |
|--------|--------|--------|
| Deployment Time | 12 minutes | 1.5 minutes |
| Infrastructure Setup | Manual | Fully Automated |
| Scalability | Static | HPA 1–3 replicas |
| Credentials | Hardcoded | Zero credentials |

---

# 🛠️ Tech Stack

### Infrastructure
AWS (EKS, EC2, VPC, IAM, ALB, RDS, DynamoDB)  
Terraform  
Kubernetes  
Helm  

### CI/CD
Jenkins (Groovy Pipelines)  
Docker  

### Monitoring
Prometheus  
Grafana  

### Databases
MySQL  
PostgreSQL  
Redis  
RabbitMQ  
DynamoDB  

### Languages
Java  
Go  
Node.js  
Bash  

---

# 🎯 What This Project Demonstrates

✔ Production-ready cloud architecture  
✔ Real-world Kubernetes orchestration  
✔ Advanced IAM & IRSA security  
✔ Infrastructure as Code mastery  
✔ CI/CD automation  
✔ Monitoring & Observability  
✔ Multi-database microservices design  

---

# 📂 Repository Structure

```
retail-store-aws-deployment/
│
├── terraform/
├── retail-store-helm-chart/
├── retail-store-Jenkins-shared-library/
├── assets/
└── README.md
```

---

# 👨‍💻 About the Engineer

**Sarthak Singh**  
DevOps Engineer | Cloud Infrastructure Specialist  
2nd Year Computer Engineering Student  

🔗 LinkedIn: https://www.linkedin.com/in/sarthak-singh-a0aa62322  
🐙 GitHub: https://github.com/Sarthakx67  
📧 Email: sarthak.devops@email.com  

---

<div align="center">

### ⭐ If you find this project valuable, consider starring the repository!

</div>
