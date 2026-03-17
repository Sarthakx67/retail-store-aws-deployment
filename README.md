<div align="center">

![Header](https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=200&section=header&text=Production%20Kubernetes%20on%20AWS&fontSize=50&fontColor=fff&animation=twinkling&fontAlignY=35)

### Cloud-Native Microservices Platform | DevOps Portfolio Project

<p align="center">
  <img src="https://img.shields.io/badge/AWS-EKS-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white" />
  <img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" />
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white" />
  <img src="https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white" />
  <img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white" />
  <img src="https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white" />
</p>

<p align="center">
  <a href="#what-i-built">What I Built</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#gitops-pipeline">GitOps</a> •
  <a href="#tech-stack">Stack</a> •
  <a href="#key-learnings">Key Learnings</a> •
  <a href="SETUP.md"><strong>📖 Full Setup Guide →</strong></a>
</p>

</div>

---

## What I Built

A 10-service retail store platform deployed on AWS EKS — built to production standards, not just as a tutorial project. Every design decision has a reason behind it.

**10 services across 2 layers:**
- 5 application microservices: UI, Cart (Java), Catalog (Go), Checkout (Node.js), Orders (Java)  
- 5 data services: MySQL, PostgreSQL, Redis, RabbitMQ, DynamoDB (local for dev / AWS for prod)

---

## Highlights

<table>
<tr>
<td width="50%" valign="top">

### What's Implemented

✅ **Full AWS Infrastructure** — VPC, EKS, IAM from scratch via Terraform  
✅ **GitOps Deployment** — ArgoCD auto-syncs every Git push to cluster  
✅ **IRSA Authentication** — Cart accesses DynamoDB without static credentials  
✅ **Umbrella Helm Chart** — 10 subcharts, layered dev/prod values  
✅ **Auto-Scaling** — HPA on all 5 application services  
✅ **Health Probes** — Startup + liveness + readiness; reduced deployment time from 12 min → 1.5 min  
✅ **Observability** — Prometheus + Grafana with custom ServiceMonitors  
✅ **Init Containers** — Catalog waits for MySQL before starting  
✅ **Persistent Storage** — EBS-backed StatefulSets for all databases  
✅ **Jenkins Shared Library** — Single 8-line Jenkinsfile per service  

</td>
<td width="50%" valign="top">

### In Progress

🔧 **Secrets Management** — Migrating to External Secrets Operator + AWS SSM  
&nbsp;&nbsp;&nbsp;&nbsp;Current: placeholder values in Helm charts  
&nbsp;&nbsp;&nbsp;&nbsp;Target: zero secrets in Git, runtime injection via ESO + IRSA  

🔧 **GitOps CI Separation** — Jenkins currently deploys via `helm upgrade`  
&nbsp;&nbsp;&nbsp;&nbsp;Target: Jenkins updates Git, ArgoCD owns all deployments  

🔧 **PodDisruptionBudgets** — Guaranteeing zero-downtime during node drains  

🔧 **AlertManager Rules** — Prometheus installed but alerting not yet configured  

</td>
</tr>
</table>

---

## Architecture

```
Internet
    ↓
Route53 (stallions.space)
    ↓
Application Load Balancer
    ↓
EKS Cluster (retail-store-prod namespace)
    ├── UI Service (Java/Spring Boot)
    │   ├── → Catalog (Go)  → MySQL (StatefulSet + EBS)
    │   ├── → Cart (Java)   → DynamoDB (via IRSA)
    │   ├── → Orders (Java) → PostgreSQL (StatefulSet + EBS)
    │   │                   → RabbitMQ (StatefulSet)
    │   └── → Checkout (Node.js) → Redis (StatefulSet)
    │
    └── Monitoring Namespace
        ├── Prometheus (scrapes all services via ServiceMonitors)
        └── Grafana (custom retail store dashboard)
```

**Key design decisions:**

| Decision | Why |
|----------|-----|
| Headless service for MySQL and PostgreSQL | StatefulSet pods need stable DNS identity for replication-ready setup |
| `tcpSocket` readiness for Catalog | Go service has no Spring Actuator — port binding is sufficient signal after init container guarantees MySQL readiness |
| `httpGet /actuator/health/readiness` for Java services | Spring Actuator checks all dependencies (DB, messaging) before returning 200 — prevents traffic routing to pods that are up but not connected |
| Init container for Catalog | `nc -z` confirms MySQL TCP socket, preventing CrashLoopBackOff during cluster cold start |
| `ignoreDifferences` on `/spec/replicas` | Prevents ArgoCD from fighting HPA over replica count during load |
| IRSA for Cart | Eliminates static AWS credentials entirely — IAM role bound to Kubernetes ServiceAccount via OIDC |

---

## GitOps Pipeline

```
Git Push
    ↓
Jenkins (CI only)
  - Detect version from Maven/Go/Node.js
  - Build Docker image
  - Push to DockerHub
    ↓
ArgoCD (CD — watches Git every 3 minutes)
  - Detects commit
  - Renders umbrella Helm chart
  - Applies diff to cluster
  - prune: true → removes deleted resources
  - selfHeal: true → reverts manual kubectl changes
```

**ArgoCD Application config:**
```yaml
ignoreDifferences:
- group: apps
  kind: Deployment
  jsonPointers:
  - /spec/replicas    # HPA owns this field, not Git
```

---

## Health Probe Design

Probes reduced deployment time from 12 minutes to 1.5 minutes by eliminating manual intervention after dependency failures.

| Service | Startup | Liveness | Readiness | Why |
|---------|---------|----------|-----------|-----|
| Cart, Orders, UI (Java) | `httpGet /actuator/health/liveness` | Same | `httpGet /actuator/health/readiness` | Spring checks all deps before returning 200 |
| Catalog (Go) | `httpGet /health` | Same | `tcpSocket :8080` | No Spring Actuator; init container handles MySQL wait |
| Checkout (Node.js) | `httpGet /health` | Same | `tcpSocket :8080` | Lightweight — port binding is sufficient |

---

## IRSA — Secretless AWS Access

Cart service accesses DynamoDB without any AWS credentials stored anywhere.

```
Cart pod starts
    ↓
EKS injects AWS_ROLE_ARN + AWS_WEB_IDENTITY_TOKEN_FILE (JWT)
    ↓
AWS SDK calls sts:AssumeRoleWithWebIdentity
    ↓
EKS OIDC provider validates the JWT
    ↓
STS returns temporary credentials (auto-rotating, 1-hour TTL)
    ↓
DynamoDB access granted — zero static credentials
```

IAM trust policy binds the role to exactly one ServiceAccount in one namespace — blast radius is minimal.

---

## Tech Stack

<div align="center">

<table>
<tr>
<td align="center" width="16%">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/amazonwebservices/amazonwebservices-original-wordmark.svg" width="55" height="55" />
<br><strong>AWS</strong>
<br><sub>EKS, VPC, IAM, DynamoDB, EBS, Route53, SSM</sub>
</td>
<td align="center" width="16%">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/kubernetes/kubernetes-plain.svg" width="55" height="55" />
<br><strong>Kubernetes</strong>
<br><sub>v1.28+ — EKS managed</sub>
</td>
<td align="center" width="16%">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/terraform/terraform-original.svg" width="55" height="55" />
<br><strong>Terraform</strong>
<br><sub>VPC, EKS, IAM, SSM modules</sub>
</td>
<td align="center" width="16%">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg" width="55" height="55" />
<br><strong>Docker</strong>
<br><sub>Multi-stage builds</sub>
</td>
<td align="center" width="16%">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/jenkins/jenkins-original.svg" width="55" height="55" />
<br><strong>Jenkins</strong>
<br><sub>Shared library CI</sub>
</td>
<td align="center" width="16%">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/prometheus/prometheus-original.svg" width="55" height="55" />
<br><strong>Prometheus</strong>
<br><sub>+ Grafana dashboards</sub>
</td>
</tr>
</table>

<br>

**Application services:** Java (Spring Boot) · Go · Node.js  
**Databases:** MySQL · PostgreSQL · Redis · RabbitMQ · DynamoDB  
**GitOps:** ArgoCD · Helm umbrella chart · layered values files  

</div>

---

## Monitoring Dashboard

**Four panels tracking production health:**

| Panel | Query | What It Catches |
|-------|-------|-----------------|
| 5xx Error Rate | `rate(http_server_requests_seconds_count{status=~"5.."}[1m])` | Application crashes, DynamoDB failures |
| CPU Usage | `process_cpu_usage` | Runaway processes, traffic spikes |
| JVM Heap Memory | `jvm_memory_used_bytes` | Memory leaks (sawtooth pattern = leak) |
| Requests Per Second | `rate(http_server_requests_seconds_count[1m])` | Traffic baseline, anomaly detection |

ServiceMonitors scrape all 5 application services on 15-second intervals.

---

## Key Learnings

Real problems hit and fixed — not hypothetical:

| Problem | Root Cause | Fix |
|---------|-----------|-----|
| ArgoCD blocking full sync | ServiceMonitor CRD missing — one invalid resource aborts everything | Install `kube-prometheus-stack` before syncing dependent apps |
| ArgoCD vs HPA infinite fight | ArgoCD reverted HPA scaling decisions within 3 minutes | `ignoreDifferences` on `/spec/replicas` — formally hands ownership to HPA |
| Helm targeting ArgoCD port-forward | `KUBECONFIG` set in `.bashrc` for ec2-user but bootstrap script ran as root | `export KUBECONFIG` in the script itself, not just `.bashrc` |
| Catalog CrashLoopBackOff on cold start | MySQL port 3306 open before initialization complete — `nc -z` returns success too early | `mysqladmin ping` in init container verifies actual readiness, not just TCP socket |
| Second cart pod not scheduling | CPU requests set to 200m but actual usage was 3m — scheduler saw node as full | Set requests from observed usage × 1.5, not from template defaults |

---

## Project Structure

```
.
├── retail-store-helm-chart/        # Umbrella Helm chart
│   ├── Chart.yaml                  # 10 subchart dependencies
│   ├── values.yaml                 # Base defaults
│   ├── charts/                     # 10 subcharts (cart, catalog, checkout...)
│   └── values/
│       ├── dev/values-dev.yaml     # Dev overrides (local DynamoDB, NodePort)
│       └── prod/values-prod.yaml   # Prod overrides (IRSA, LoadBalancer, EBS)
│
├── argocd-deployment/              # ArgoCD Application manifests
│   ├── retail-store-app-dev.yaml
│   └── retail-store-app-prod.yaml
│
├── retail-store-Jenkins-shared-library/  # Groovy shared library
│   ├── detectVersion.groovy        # Maven / Go / Node.js version detection
│   ├── dockerBuildPush.groovy      # Build + push to DockerHub
│   ├── deployK8s.groovy            # Helm deploy (migrating to Git update)
│   └── microservicePipeline.groovy # Single-call pipeline definition
│
├── src/                            # Dockerfiles for all 5 services
├── aws-ec2-manual-terraform-deployment/  # Earlier EC2-based iteration (learning reference)
└── SETUP.md                        # Complete deployment guide with ordered steps
```

---

## Deployment

Full deployment guide is in **[SETUP.md](SETUP.md)**.

It covers the complete ordered dependency chain — EKS cluster, EBS CSI driver, IRSA setup, monitoring namespace, Helm deploy — with troubleshooting for every common failure mode. Run steps out of order and things break in non-obvious ways. The ordering matters.

> **Why a separate setup file?** The deployment sequence has real dependencies between steps. Collapsing it into a quick-start snippet creates the illusion it's simpler than it is.

---

## Honest Status

This project is in active development. Here's what works end-to-end and what doesn't yet:

**Works completely:**
- Full EKS cluster provisioning via Terraform
- Helm umbrella chart with 10 services deploying cleanly
- ArgoCD GitOps syncing from GitHub
- IRSA for DynamoDB access without static credentials
- HPA auto-scaling on all application services
- Prometheus scraping + Grafana dashboards
- Health probes with init container dependency management

**Known gaps being actively worked on:**
- Secrets still use placeholder values — External Secrets Operator implementation in progress
- Jenkins deploys directly to cluster — should update Git instead (ArgoCD conflict)
- No AlertManager rules configured yet
- PodDisruptionBudgets not implemented — node drains could cause downtime

---

<div align="center">

<p align="center">
  <a href="https://www.linkedin.com/in/sarthak-singh-a0aa62322">
    <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" />
  </a>
  <a href="https://github.com/Sarthakx67">
    <img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white" />
  </a>
</p>

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=100&section=footer" width="100%">

</div>