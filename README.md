<!-- # Hi, I'm Sarthak Singh 👋

**DevOps Engineer | Cloud Infrastructure Specialist | 2nd Year Computer Engineering Student**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/sarthak-singh-a0aa62322)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?style=for-the-badge&logo=github)](https://github.com/Sarthakx67)
[![Email](https://img.shields.io/badge/Email-Contact-red?style=for-the-badge&logo=gmail)](mailto:sarthak.devops@email.com)

---

## 🎯 What I Do

I build **production-grade cloud infrastructure** that is:
- **Secure** (Zero-trust architecture, IRSA, no hardcoded credentials)
- **Scalable** (Auto-scaling, load balancing, multi-AZ deployments)
- **Observable** (Prometheus, Grafana, distributed tracing)
- **Automated** (Infrastructure as Code, CI/CD pipelines)

I specialize in transforming complex microservices applications into production-ready deployments on AWS and Kubernetes.

---

## 🛠️ Technical Skills

### Cloud & Infrastructure
![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat-square&logo=amazon-aws&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat-square&logo=helm&logoColor=white)

**AWS Services**: EKS, EC2, VPC, IAM, DynamoDB, RDS, Route53, ALB, EBS, SSM Parameter Store  
**Container Orchestration**: Kubernetes, EKS, K3s, Helm Charts, StatefulSets, HPA  
**Infrastructure as Code**: Terraform (modular architecture), Helm (umbrella charts)

### CI/CD & Automation
![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=flat-square&logo=jenkins&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)

**Pipelines**: Jenkins (Groovy), Shared Libraries, Multi-stage builds  
**Version Control**: Git, GitHub  
**Scripting**: Bash, Shell scripting for automation

### Monitoring & Observability
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat-square&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat-square&logo=grafana&logoColor=white)

**Monitoring**: Prometheus (ServiceMonitor, custom metrics)  
**Visualization**: Grafana dashboards (request rates, error rates, latency, resource utilization)  
**Observability**: Application metrics, Kubernetes metrics, health probes

### Databases & Messaging
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=flat-square&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=flat-square&logo=redis&logoColor=white)
![RabbitMQ](https://img.shields.io/badge/RabbitMQ-FF6600?style=flat-square&logo=rabbitmq&logoColor=white)

**Databases**: MySQL, PostgreSQL, DynamoDB, Redis  
**Message Queues**: RabbitMQ  
**Storage**: EBS CSI Driver, Persistent Volumes, StatefulSets

### Programming & Scripting
![Java](https://img.shields.io/badge/Java-007396?style=flat-square&logo=java&logoColor=white)
![Go](https://img.shields.io/badge/Go-00ADD8?style=flat-square&logo=go&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat-square&logo=node.js&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)

**Languages**: Java, Go, Node.js, Python, Bash  
**Frameworks**: Spring Boot, Gin (Go), Express.js

---

## 🚀 Featured Project: AWS Retail Store Microservices Platform

**A production-grade, cloud-native microservices deployment showcasing enterprise DevOps practices**

[![View Project](https://img.shields.io/badge/View_Project-GitHub-black?style=for-the-badge&logo=github)](https://github.com/Sarthakx67/retail-store-aws-deployment)

### 📋 Project Overview

Deployed a polyglot microservices application (5 services + 4 databases) on AWS EKS with complete automation, security, and observability. This project demonstrates real-world DevOps engineering skills used in enterprise environments.

### 🏗️ Architecture Highlights

**Multi-Tier Cloud Infrastructure**
- **Network**: Custom VPC with public/private subnet isolation across multiple AZs
- **Compute**: AWS EKS cluster with worker nodes in private subnets (no internet exposure)
- **Security**: IAM Roles for Service Accounts (IRSA) - zero hardcoded credentials
- **Storage**: Dynamic EBS provisioning via CSI driver for stateful workloads
- **Ingress**: AWS Application Load Balancer for external traffic management

**Microservices Stack**
- **UI Service** (Java/Spring Boot) - Customer frontend
- **Cart Service** (Java/Spring Boot) - Shopping cart with DynamoDB
- **Catalog Service** (Go/Gin) - Product catalog with MySQL
- **Orders Service** (Java/Spring Boot) - Order management with PostgreSQL
- **Checkout Service** (Node.js) - Payment processing with Redis

### 🔑 Key Technical Achievements

#### 1. Infrastructure as Code (Terraform)
```
✅ Modular Terraform structure (VPC, EKS, IAM, Security Groups)
✅ Remote state management for team collaboration
✅ Parameterized configurations using SSM Parameter Store
✅ Zero-downtime infrastructure updates
```

#### 2. Kubernetes Orchestration (Helm)
```
✅ Umbrella chart pattern for unified deployments
✅ Environment-specific configurations (dev/K3s vs prod/EKS)
✅ Horizontal Pod Autoscaling (HPA) based on CPU/memory
✅ Liveness, Readiness, and Startup probes for self-healing
✅ StatefulSets for databases with persistent storage
```

#### 3. Security & IAM
```
✅ IRSA (IAM Roles for Service Accounts) - no AWS keys in code
✅ OIDC integration between EKS and AWS IAM
✅ Least-privilege IAM policies per service
✅ Private subnet deployment for worker nodes
✅ Security groups with minimal ingress rules
```

#### 4. CI/CD Pipeline (Jenkins)
```
✅ Automated version detection from source code
✅ Multi-stage Docker builds for optimized images
✅ Automated image tagging and push to container registry
✅ Helm-based deployment automation
✅ Shared pipeline libraries for code reusability
```

#### 5. Observability & Monitoring
```
✅ Prometheus for metrics collection
✅ Grafana dashboards for visualization
✅ ServiceMonitor resources for automatic scraping
✅ Custom metrics: request rates, error rates, P95 latency
✅ Resource monitoring: CPU, memory, pod restarts
```

### 📊 Metrics & Results

| Metric | Achievement |
|--------|-------------|
| **Deployment Time** | 12 min → 1.5 min (with health probes) |
| **Infrastructure Provisioning** | Fully automated via Terraform |
| **Service Availability** | 99.9%+ with HPA and health checks |
| **Security** | Zero hardcoded credentials |
| **Scalability** | Auto-scaling from 1 to 3 replicas per service |

### 🛠️ Technologies Used

**Infrastructure**: AWS (EKS, EC2, VPC, IAM, ALB, DynamoDB, RDS), Terraform  
**Container Orchestration**: Kubernetes, Helm, Docker  
**CI/CD**: Jenkins (Groovy pipelines), Docker  
**Monitoring**: Prometheus, Grafana  
**Databases**: MySQL, PostgreSQL, Redis, RabbitMQ, DynamoDB  
**Languages**: Java, Go, Node.js, Bash

### 📁 Project Structure
```
📦 retail-store-aws-deployment/
├── 📂 terraform/                    # Infrastructure as Code
│   ├── vpc/                         # Network infrastructure
│   ├── firewall/                    # Security groups
│   ├── cart/ catalog/ orders/ ui/   # EC2 deployments (legacy)
│   └── vpn/                         # Bastion host
├── 📂 retail-store-helm-chart/      # Kubernetes deployment
│   ├── Chart.yaml                   # Umbrella chart definition
│   ├── charts/                      # Individual service charts
│   │   ├── cart/
│   │   ├── catalog/
│   │   ├── checkout/
│   │   ├── orders/
│   │   ├── ui/
│   │   └── databases (mysql, postgresql, redis, rabbitmq)
│   └── values/                      # Environment-specific configs
│       ├── k3s/                     # Local development
│       └── eks/                     # Production
└── 📂 retail-store-Jenkins-shared-library/  # CI/CD automation
    ├── microservicePipeline.groovy
    ├── detectVersion.groovy
    ├── dockerBuildPush.groovy
    └── deployK8s.groovy
```

### 🎯 What This Project Demonstrates

**For Hiring Managers:**
- ✅ Real-world production deployment experience
- ✅ Cloud architecture design and implementation
- ✅ Security best practices (IRSA, zero credentials)
- ✅ Full-stack DevOps: from code to production
- ✅ Monitoring and observability setup

**For Technical Interviewers:**
- ✅ Deep Kubernetes knowledge (StatefulSets, HPA, probes)
- ✅ AWS expertise (EKS, IAM, VPC design)
- ✅ Infrastructure as Code proficiency
- ✅ CI/CD pipeline design and implementation
- ✅ Production debugging and troubleshooting

---

## 💼 Why Work With Me?

### Production-Ready Mindset
I don't just deploy applications - I build **resilient, secure, observable systems** that work at scale. Every architectural decision is backed by understanding of production requirements.

### Continuous Learning
As a 2nd-year engineering student, I'm actively learning and implementing the latest DevOps practices. I combine academic knowledge with hands-on production experience.

### Problem-Solving Approach
I approach infrastructure challenges systematically:
1. Understand requirements and constraints
2. Design with security and scalability in mind
3. Implement with automation and observability
4. Document and iterate

---

## 📈 Current Focus

- 🔭 Building more production-grade cloud-native applications
- 🌱 Deep diving into Kubernetes internals and advanced patterns
- 👯 Open to collaborating on DevOps and cloud infrastructure projects
- 💼 Seeking DevOps/Cloud Engineer internship or entry-level opportunities

---

## 📫 Let's Connect!

I'm actively looking for opportunities to contribute to production infrastructure and DevOps teams.

**Best ways to reach me:**
- 💼 LinkedIn: [linkedin.com/in/sarthak-singh-a0aa62322](https://www.linkedin.com/in/sarthak-singh-a0aa62322)
- 📧 Email: sarthak.devops@email.com
- 🐙 GitHub: [@Sarthakx67](https://github.com/Sarthakx67)

**What I'm looking for:**
- DevOps Engineer roles
- Cloud Infrastructure positions
- Site Reliability Engineering (SRE) opportunities
- Platform Engineering roles
- Internships in DevOps/Cloud

---

<div align="center">

### ⭐ If you find my work interesting, consider starring my repositories!

**"Building secure, scalable, and observable cloud infrastructure - one deployment at a time."**

![Profile Views](https://komarev.com/ghpvc/?username=Sarthakx67&color=blue&style=flat-square)

</div> -->

# 🛒 Sarthak Singh | DevOps & Platform Engineer 👋
### "Architecting Secure, Scalable, and Observable Systems"

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/sarthak-singh-a0aa62322)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?style=for-the-badge&logo=github)](https://github.com/Sarthakx67)
[![Availability](https://img.shields.io/badge/Availability-Internship_May_2026-brightgreen?style=for-the-badge)](https://www.linkedin.com/in/sarthak-singh-a0aa62322)

---

## 🎯 Professional Summary
I am a 2nd-year Computer Engineering student building **production-grade cloud infrastructure**. I specialize in transforming complex microservices into resilient, automated ecosystems. My philosophy centers on **Security (Zero-Trust)**, **Scalability**, and **Observability**.

---

## 🛠️ Technical Arsenal
| Cloud & Orchestration | CI/CD & Automation | Observability & Data |
| :--- | :--- | :--- |
| ![AWS](https://img.shields.io/badge/AWS-232F3E?logo=amazon-aws&style=flat-square) | ![Jenkins](https://img.shields.io/badge/Jenkins-D24939?logo=jenkins&style=flat-square) | ![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?logo=prometheus&style=flat-square) |
| ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&style=flat-square) | ![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&style=flat-square) | ![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana&style=flat-square) |
| ![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&style=flat-square) | ![Ansible](https://img.shields.io/badge/Ansible-EE0000?logo=ansible&style=flat-square) | ![MySQL](https://img.shields.io/badge/MySQL-4479A1?logo=mysql&style=flat-square) |

---

## 🚀 Featured Project: AWS Retail Store Microservices
**A Production-Grade, Cloud-Native Platform**


### 🖼️ Evidence of Work (System Gallery)
| Application Frontend | Kubernetes Resource Health | Prometheus Monitoring |
| :---: | :---: | :---: |
| <img src="assets/01-ui.png" width="250" /> | <img src="assets/status-pod-svc-pv-pvc.png" width="250" /> | <img src="assets/application-services.png" width="250" /> |
| *01-ui.png* | *status-pod-svc-pv-pvc.png* | *application-services.png* |

### 🔑 Key Engineering Achievements
* **IaC & Automation:** 100% automated provisioning via **Modular Terraform**. Modularized VPC, EKS, and IAM for zero-drift deployments.
* **Zero-Trust Security:** Implemented **IRSA (IAM Roles for Service Accounts)**. Services interact with DynamoDB via OIDC tokens, eliminating hardcoded credentials.
* **Advanced CI/CD:** Built a custom **Jenkins Shared Library** in Groovy to standardize multi-stage builds and automated Helm deployments.
* **Observability:** Full stack monitoring using **Prometheus & Grafana** with custom ServiceMonitors for request rates and P95 latency.

---

## 📊 Metrics & Impact
* **Deployment Efficiency:** Setup time reduced from hours to **~12 minutes** via IaC.
* **Self-Healing:** Configured Liveness/Readiness probes + HPA, ensuring **99.9% availability** during traffic spikes.
* **Optimized Storage:** Dynamic EBS provisioning using the **EBS CSI Driver**.

---

## 💼 Why Work With Me?
- **Production-Ready Mindset:** I build for "Day 2 Operations" (scaling, logging, patching).
- **Systems Thinking:** I bridge the gap between application code (Java/Go/Node) and infrastructure performance.
- **Fast Mover:** Seeking a **DevOps/SRE Internship for Summer 2026** and ready to clear technical rounds today.

---

## 📫 Let's Connect!
- **LinkedIn:** [linkedin.com/in/sarthak-singh-a0aa62322](https://www.linkedin.com/in/sarthak-singh-a0aa62322)
- **GitHub:** [@Sarthakx67](https://github.com/Sarthakx67)
- **Email:** [sarthak.devops@email.com]

<div align="center">
  <img src="https://komarev.com/ghpvc/?username=Sarthakx67&color=blue&style=flat-square" />
  <br>
  <b>Building secure, scalable, and observable cloud infrastructure.</b>
</div>