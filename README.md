# 🛒 AWS Retail Store: Production-Grade Microservices Deployment
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&style=flat-square)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Orchestration-AWS%20EKS-326CE5?logo=kubernetes&style=flat-square)](https://aws.amazon.com/eks/)
[![Helm](https://img.shields.io/badge/Packaging-Helm-0F1689?logo=helm&style=flat-square)](https://helm.sh/)
[![Jenkins](https://img.shields.io/badge/CI%2FCD-Jenkins-D24939?logo=jenkins&style=flat-square)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker&style=flat-square)](https://www.docker.com/)

> **An enterprise-ready deployment of a polyglot microservices application, featuring automated Infrastructure as Code (IaC), zero-trust security models, and fully automated Jenkins CI/CD pipelines.**

---

## 🏗️ System Architecture
This project implements a highly available, multi-tier architecture across multiple Availability Zones (AZs) in the `ap-south-1` region, focusing on network isolation and security.



### Infrastructure Highlights:
* **Networking:** Custom VPC with 3 Public and 3 Private subnets. EKS worker nodes are isolated in **Private Subnets** to ensure no direct internet exposure.
* **Security (IRSA):** Implemented **IAM Roles for Service Accounts**. The `Cart` service uses OIDC to assume specific IAM roles for DynamoDB access, eliminating the need for hardcoded AWS access keys.
* **Storage:** Dynamic provisioning using the **AWS EBS CSI Driver** for persistent data across MySQL, PostgreSQL, and Redis.
* **Ingress:** Managed via **AWS Application Load Balancer (ALB)**, providing a single entry point for the frontend UI.

---

## 🛠️ Engineering Stack
| Layer | Technology | Key Implementation |
| :--- | :--- | :--- |
| **Cloud Provider** | **AWS** | EKS, ECR, DynamoDB, VPC, IAM, ALB |
| **IaC** | **Terraform** | Modularized structure (VPC, EKS, IAM modules) |
| **Orchestration** | **Kubernetes** | Helm Umbrella Charts, HPA, Namespaces |
| **CI/CD** | **Jenkins** | Groovy-based declarative pipelines |
| **Data Stores** | **Polyglot** | MySQL, PostgreSQL, Redis, RabbitMQ |
| **Runtime** | **Docker** | Multi-stage builds for optimized image size |

---

## 🚀 Key DevOps Patterns & Achievements

### 1. Declarative Infrastructure (Terraform)
All infrastructure is managed via Terraform modules. This ensures the environment is reproducible and prevents "configuration drift."
* **Modular Design:** Separate modules for networking, compute, and security.
* **State Management:** (Optional: Mention if using S3/DynamoDB for remote state).

### 2. Automated Scaling & Self-Healing
* **HPA (Horizontal Pod Autoscaler):** Configured to scale replicas based on CPU/Memory utilization to handle traffic spikes.
* **Probes:** Integrated Liveness and Readiness probes to ensure the Load Balancer only routes traffic to healthy containers.

### 3. CI/CD Pipeline (Jenkins)
A robust pipeline that bridges the gap between development and production:
1.  **Code Quality:** Linting and validation of Dockerfiles/Helm charts.
2.  **Security:** Multi-stage builds to ensure small, secure production images.
3.  **Automation:** Automated image tagging and pushing to **AWS ECR**.
4.  **Deployment:** One-click deployment/update via **Helm** into the EKS cluster.

---

## 📂 Repository Structure
```text
├── terraform/               # Infrastructure as Code (VPC, EKS, Security Groups)
├── retail-store-helm-chart/ # Production Helm charts (Umbrella pattern)
└── jenkins/                 # Groovy Pipeline (Jenkinsfile)

```

---

## 👨‍💻 About Me

I am a 2nd-year Computer Engineering student and aspiring DevOps Engineer. I focus on building systems that are **Secure, Scalable, and Observable.**

**Let's Connect:**
[LinkedIn](https://www.google.com/search?q=https://www.linkedin.com/in/sarthak-singh-a0aa62322) | [GitHub](https://www.google.com/search?q=https://github.com/Sarthakx67) 

---

