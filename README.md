To make your profile stand out to recruiters and senior engineers, I’ve refined the layout to use a **professional grid system**, high-quality badges, and a clear "Problem/Solution" narrative for your project.

Here is the enhanced, fully coded Markdown.

```markdown
# Hi, I'm Sarthak Singh 👋 
### **DevOps & Platform Engineer | Cloud Infrastructure Specialist**

<div align="center">

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/sarthak-singh-a0aa62322)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?style=for-the-badge&logo=github)](https://github.com/Sarthakx67)
[![Email](https://img.shields.io/badge/Email-Contact-red?style=for-the-badge&logo=gmail)](mailto:sarthak.devops@email.com)

**Building resilient, secure, and observable distributed systems at scale.**
*Currently a 2nd Year Computer Engineering Student specializing in Cloud-Native Architectures.*

</div>

---

## 🛠️ Technical Ecosystem

| Category | Tools & Technologies |
| :--- | :--- |
| **Cloud & IaC** | ![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat-square&logo=amazon-aws&logoColor=white) ![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white) ![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat-square&logo=helm&logoColor=white) |
| **Containerization** | ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white) ![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white) ![EKS](https://img.shields.io/badge/AWS_EKS-FF9900?style=flat-square&logo=amazon-aws&logoColor=white) |
| **CI/CD & Automation** | ![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=flat-square&logo=jenkins&logoColor=white) ![Git](https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git&logoColor=white) ![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white) |
| **Observability** | ![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat-square&logo=prometheus&logoColor=white) ![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat-square&logo=grafana&logoColor=white) |
| **Languages** | ![Java](https://img.shields.io/badge/Java-007396?style=flat-square&logo=java&logoColor=white) ![Go](https://img.shields.io/badge/Go-00ADD8?style=flat-square&logo=go&logoColor=white) ![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white) |

---

## 🚀 Featured Project: AWS Retail Store Platform
> **A production-grade, polyglot microservices deployment demonstrating enterprise DevOps standards.**

### 🖥️ Project Showcase (Live Application)
*The application spans 5 microservices (Spring Boot, Go, Node.js) with 4 different database backends.*

| **Storefront (UI)** | **Catalog Management** | **Order Processing** |
| :---: | :---: | :---: |
| ![UI](01-ui.png) | ![Catalog](02-catalog.png) | ![Orders](07-orders.png) |
| *High-availability UI* | *Dynamic Catalog Service* | *PostgreSQL Persistence* |

<details>
<summary><b>🔍 View Multi-Step Checkout Workflow</b></summary>

| Step 1: Cart | Step 2: Shipping | Step 3: Payment |
| :---: | :---: | :---: |
| ![Cart](03-cart.png) | ![Check1](04-checkout-1.png) | ![Check2](05-checkout-2.png) |

</details>

---

### 🏗️ Infrastructure Architecture & Engineering
This project transitions from "working code" to a "production system" through hardened infrastructure.

#### **1. Kubernetes Orchestration & Cluster State**
The EKS cluster utilizes private subnets and Application Load Balancers (ALB) for secure traffic ingress.
![K8s Status](status-pod-svc-pv-pvc.png)
*Real-time validation of Pods, Services, and Persistent Volume Claims (PVC).*

#### **2. Persistent Storage & Database Layer**
Implemented **StatefulSets** with the **AWS EBS CSI Driver** for dynamic volume provisioning.
* **Storage Proof:** ![Volumes](volumes.png)
* **Live DB Query:** ![Postgres](postgresql-orders.png) *(Validating order data in PostgreSQL)*

#### **3. Compute & Scaling**
![EKS Nodes](eks-nodes-workstation.png)
*Cluster Health: High-availability worker nodes distributed across multiple AZs.*

---

### 🔑 Key Engineering Highlights
* **Security First:** Implemented **IRSA (IAM Roles for Service Accounts)** to ensure pods have least-privilege access without hardcoded secrets.
* **Automated Lifecycle:** Developed **Jenkins Shared Libraries** to standardize CI/CD across all microservices (Build ➔ Scan ➔ Deploy).
* **IaC Mastery:** 100% of the AWS infrastructure (VPC, EKS, IAM, Security Groups) is provisioned via **Modular Terraform**.
* **Observability:** Integrated **Prometheus ServiceMonitors** to automate metric scraping for Grafana dashboards.

---

### 📂 Repository Structure
```bash
📦 retail-store-aws-deployment
├── 📂 terraform/              # VPC, EKS, and IAM Modules
├── 📂 retail-store-helm-chart/ # Umbrella Chart pattern for unified deploy
│   ├── 📂 charts/             # Sub-charts for UI, Cart, Catalog, etc.
│   └── 📂 values/             # EKS (Prod) vs K3s (Dev) configs
├── 📂 shared-library/         # Jenkins Groovy logic for CI/CD reuse
└── 📂 src/                    # Polyglot Application Source Code

```

---

## 📈 Let's Connect

I am actively seeking **DevOps/Cloud Internships** and open-source collaborations focused on Platform Engineering.

* 🔭 **Current Focus:** Kubernetes Internals & Go-based Operators.
* 💬 **Ask me about:** Automation, Infrastructure Security, and CI/CD best practices.
* ⚡ **Goal:** Building systems that are bored by 10x traffic spikes.

<div align="center">

**"Infrastructure as Code. Security as Standard. Observability as Default."**

</div>

```