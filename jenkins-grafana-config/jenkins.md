# 🚀 Retail Store Microservices - CI/CD Pipeline Documentation

Complete CI/CD implementation guide for a production-grade microservices platform using Jenkins, Docker, Helm, and Kubernetes.

---

## 📋 Table of Contents

- [CI/CD Overview](#cicd-overview)
- [Architecture](#architecture)
- [Jenkins Infrastructure Setup](#jenkins-infrastructure-setup)
- [Shared Library Implementation](#shared-library-implementation)
- [Pipeline Stages Deep Dive](#pipeline-stages-deep-dive)
- [Service-Specific Pipelines](#service-specific-pipelines)
- [Version Management Strategy](#version-management-strategy)
- [Docker Image Management](#docker-image-management)
- [Helm Deployment Strategy](#helm-deployment-strategy)
- [Environment Management](#environment-management)
- [Security & Credentials](#security--credentials)
- [Rollback Strategies](#rollback-strategies)
- [Pipeline Execution Flow](#pipeline-execution-flow)
- [Troubleshooting CI/CD](#troubleshooting-cicd)
- [Best Practices Implemented](#best-practices-implemented)
- [Advanced Topics](#advanced-topics)

---

## 🎯 CI/CD Overview

### Purpose

Automated continuous integration and deployment pipeline for 5 microservices:
- **Cart** (Spring Boot + Maven)
- **Catalog** (Go)
- **Checkout** (Node.js)
- **Orders** (Spring Boot + Maven)
- **UI** (Spring Boot + Maven)

### Goals

1. **Zero Manual Deployment**: Fully automated from commit to production
2. **DRY Principle**: Single shared library for all services
3. **Version Automation**: Automatic version detection from source
4. **Environment Separation**: Clean dev/prod deployment separation
5. **Rollback Capability**: Quick rollback to previous versions
6. **Audit Trail**: Complete deployment history

### Pipeline Flow Overview

```
Code Commit → Jenkins Trigger → Version Detection → Docker Build → 
Push to Registry → Checkout Helm Repo → Helm Deploy → Verification
```

---

## 🏗️ Architecture

### High-Level CI/CD Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          Developer                               │
│                    (Commits to Git Repo)                         │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │   GitHub      │
                    │  Repository   │
                    └───────┬───────┘
                            │ (Webhook/Polling)
                            ▼
┌───────────────────────────────────────────────────────────────────┐
│                       JENKINS SERVER                               │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    Jenkins Master                            │  │
│  │  - Orchestrates pipelines                                   │  │
│  │  - Manages shared library                                   │  │
│  │  - Stores credentials                                       │  │
│  └────────────────────────┬────────────────────────────────────┘  │
│                           │                                        │
│                           ▼                                        │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    Jenkins Agent (AGENT-1)                   │  │
│  │  - Executes pipeline jobs                                   │  │
│  │  - Has Docker installed                                     │  │
│  │  - Has kubectl configured                                   │  │
│  │  - Has Helm installed                                       │  │
│  └────────────────────────┬────────────────────────────────────┘  │
└────────────────────────────┼───────────────────────────────────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
                ▼            ▼            ▼
        ┌─────────────┐  ┌─────────┐  ┌─────────────┐
        │   Docker    │  │  Helm   │  │  Kubernetes │
        │   Registry  │  │  Repo   │  │   Cluster   │
        │  (Docker    │  │ (GitHub)│  │  (K3s/EKS)  │
        │    Hub)     │  │         │  │             │
        └─────────────┘  └─────────┘  └─────────────┘
```

### Component Responsibilities

| Component         | Responsibility                                  |
|-------------------|-------------------------------------------------|
| GitHub            | Source code repository, triggers builds         |
| Jenkins Master    | Pipeline orchestration, shared library hosting  |
| Jenkins Agent     | Job execution, Docker builds, Helm deployments  |
| Docker Hub        | Container image registry                        |
| Helm Repository   | Kubernetes manifests and charts                 |
| K3s/EKS Cluster   | Application runtime environment                 |

### Pipeline Architecture Pattern

**Traditional Approach** (Without Shared Library):
```
Service 1: Jenkinsfile (200 lines)
Service 2: Jenkinsfile (200 lines) → 95% duplicate code
Service 3: Jenkinsfile (200 lines)
Service 4: Jenkinsfile (200 lines)
Service 5: Jenkinsfile (200 lines)
```

**Our Approach** (With Shared Library):
```
Shared Library (vars/):
├── microservicePipeline.groovy (main pipeline)
├── detectVersion.groovy (version extraction)
├── dockerBuildPush.groovy (Docker operations)
└── deployK8s.groovy (Helm deployment)

Service Jenkinsfiles (5-10 lines each):
├── cart/Jenkinsfile
├── catalog/Jenkinsfile
├── checkout/Jenkinsfile
├── orders/Jenkinsfile
└── ui/Jenkinsfile
```

---

## 🔧 Jenkins Infrastructure Setup

### 1. Jenkins Deployment on Kubernetes

**Deployment Method**: Jenkins runs inside the same Kubernetes cluster

**Key Configuration Files**:
- `jenkins-grafana-config/manifest.yaml` - Jenkins deployment manifest

**Deployment Resources**:
```bash
# Deploy Jenkins
kubectl apply -f jenkins-grafana-config/manifest.yaml

# Components created:
# - Namespace: jenkins
# - ServiceAccount: jenkins (with cluster-admin)
# - PersistentVolumeClaim: jenkins-pvc (10Gi)
# - Deployment: jenkins (Jenkins LTS)
# - Service: jenkins-service (NodePort 30090)
```

**Access Jenkins**:
```bash
# Get initial admin password
kubectl exec -n jenkins -it deploy/jenkins -- \
  cat /var/jenkins_home/secrets/initialAdminPassword

# Access via NodePort
http://<NODE_IP>:30090
```

### 2. Required Jenkins Plugins

Install these plugins in Jenkins:

```yaml
Essential Plugins:
  - Pipeline (Workflow Aggregator)
  - Pipeline: Stage View
  - Pipeline Utility Steps  # Required for readJSON
  - Git
  - Credentials Binding
  - Docker Pipeline
  - Kubernetes CLI

Optional (Recommended):
  - Blue Ocean
  - GitHub Branch Source
  - Pipeline Graph View
```

**Installation Commands**:
```bash
# Via Jenkins CLI
java -jar jenkins-cli.jar -s http://localhost:8080/ \
  install-plugin workflow-aggregator pipeline-stage-view \
  pipeline-utility-steps git credentials-binding \
  docker-workflow kubernetes-cli

# Restart Jenkins
kubectl rollout restart deployment/jenkins -n jenkins
```

### 3. Jenkins Agent Configuration

**Agent Requirements**:
- Label: `AGENT-1`
- Tools installed: Docker, kubectl, Helm, Maven, Node.js, Go

**Setup Agent Node**:

```bash
# On agent machine

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker jenkins

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Configure kubectl
mkdir -p /home/jenkins/.kube
# Copy kubeconfig from master or use service account

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install build tools
# Maven (for Cart, Orders, UI)
sudo yum install maven -y  # or apt-get

# Node.js (for Checkout)
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install nodejs -y

# Go (for Catalog)
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
```

**Configure Agent in Jenkins UI**:
```
Manage Jenkins → Manage Nodes → New Node
Name: AGENT-1
Type: Permanent Agent
Remote root directory: /home/jenkins
Labels: AGENT-1
Launch method: Launch agents via SSH
```

### 4. Configure Shared Library in Jenkins

**Setup Steps**:

1. Navigate to: `Manage Jenkins` → `System Configuration` → `Global Pipeline Libraries`

2. Add Library:
   ```
   Name: retail-lib
   Default version: main
   ☑ Load implicitly (trust this library)
   ☑ Allow default version to be overridden
   
   Retrieval method: Modern SCM
   Source Code Management: Git
   Project Repository: https://github.com/Sarthakx67/retail-store-aws-deployment.git
   
   Library Path: vars/
   ```

3. **Important**: Mark as "Trusted" to allow unrestricted execution

**Verify Library**:
```groovy
// In any pipeline
@Library('retail-lib') _
echo "Shared library loaded successfully"
```

### 5. Credentials Configuration

**Required Credentials**:

1. **Docker Hub Credentials** (`dockerhub-creds`):
   ```
   Kind: Username with password
   ID: dockerhub-creds
   Username: sarthak6700
   Password: <docker-hub-token>
   ```

2. **Kubernetes Config** (if using external cluster):
   ```
   Kind: Secret file
   ID: kubeconfig
   File: Upload kubeconfig file
   ```

**Create Credentials**:
```
Manage Jenkins → Credentials → System → Global credentials → Add Credentials
```

### 6. Backup and Restore

**Backup Jenkins Home**:
```bash
# Backup
kubectl cp jenkins/jenkins-pod:/var/jenkins_home ./jenkins-backup

# Restore
kubectl cp ./jenkins-backup jenkins/jenkins-pod:/var/jenkins_home
```

---

## 📚 Shared Library Implementation

### Directory Structure

```
vars/
├── microservicePipeline.groovy    # Main pipeline orchestrator
├── detectVersion.groovy           # Version extraction logic
├── dockerBuildPush.groovy         # Docker build and push
└── deployK8s.groovy              # Helm deployment logic
```

### 1. microservicePipeline.groovy

**Purpose**: Main pipeline orchestrator that coordinates all stages

**Key Features**:
- Accepts service-specific configuration
- Orchestrates all pipeline stages
- Handles errors and post-actions
- Provides consistent pipeline structure

**Parameters**:
```groovy
config.service    // Service name: cart, catalog, checkout, orders, ui
config.type       // Build type: maven, go, node
config.namespace  // K8s namespace: dev, prod
config.env        // Environment: k3s, eks
config.agent      // Optional: Jenkins agent label (default: AGENT-1)
```

**Usage Pattern**:
```groovy
@Library('retail-lib') _

microservicePipeline(
    service: "cart",
    type: "maven",
    namespace: "prod",
    env: "eks"
)
```

**Implementation Highlights**:
```groovy
def call(Map config) {
    pipeline {
        agent { label config.agent ?: 'AGENT-1' }
        
        stages {
            stage('Detect Version') {
                steps {
                    detectVersion(service: config.service, type: config.type)
                }
            }
            
            stage('Build & Push Image') {
                steps {
                    dockerBuildPush(service: config.service)
                }
            }
            
            stage('Checkout Helm Repo') {
                steps {
                    dir('helm-repo') {
                        git url: 'https://github.com/Sarthakx67/retail-store-aws-deployment.git',
                            branch: 'main'
                    }
                }
            }
            
            stage('Deploy') {
                steps {
                    deployK8s(
                        service: config.service,
                        version: env.VERSION,
                        namespace: config.namespace,
                        env: config.env
                    )
                }
            }
        }
        
        post {
            always {
                sh 'docker logout || true'
            }
            success {
                echo "✅ Deployment successful!"
            }
            failure {
                echo "❌ Deployment failed!"
            }
        }
    }
}
```

**Why This Pattern Works**:
- **DRY**: Single source of truth for pipeline logic
- **Maintainability**: Change once, affects all services
- **Consistency**: Same pipeline behavior across services
- **Flexibility**: Parameters allow service-specific customization

---

### 2. detectVersion.groovy

**Purpose**: Automatically extract version from source code based on project type

**Supported Project Types**:
- **Maven** (pom.xml)
- **Go** (version comment in main.go)
- **Node.js** (package.json)

**Implementation**:

```groovy
def call(Map config) {
    script {
        def version
        
        if (config.type == 'maven') {
            // Extract from pom.xml
            version = sh(
                script: """
                    cd src/${config.service}
                    mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tail -n 1
                """,
                returnStdout: true
            ).trim()
        }
        
        else if (config.type == 'go') {
            // Extract from main.go version comment
            // Example: // @version 1.0.0
            version = sh(
                script: """
                    cd src/${config.service}
                    grep -oP '@version\\s+\\K[0-9.]+' main.go
                """,
                returnStdout: true
            ).trim()
        }
        
        else if (config.type == 'node') {
            // Extract from package.json
            def packageJson = readJSON file: "src/${config.service}/package.json"
            version = packageJson.version
        }
        
        // Set environment variables
        env.VERSION = version
        env.IMAGE = "sarthak6700/retail-store-${config.service}:${version}"
        
        echo "✅ Version detected: ${version}"
        echo "🐳 Docker image: ${env.IMAGE}"
    }
}
```

**Version Detection Examples**:

**Maven (Cart, Orders, UI)**:
```xml
<!-- pom.xml -->
<project>
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.amazon.aws</groupId>
    <artifactId>retail-store-sample-cart</artifactId>
    <version>1.0.0</version>  <!-- ← This is extracted -->
</project>
```

Command executed:
```bash
cd src/cart
mvn help:evaluate -Dexpression=project.version -q -DforceStdout
# Output: 1.0.0
```

**Go (Catalog)**:
```go
// main.go
// @version 1.0.0  ← This is extracted
package main

func main() {
    // ...
}
```

Command executed:
```bash
cd src/catalog
grep -oP '@version\s+\K[0-9.]+' main.go
# Output: 1.0.0
```

**Node.js (Checkout)**:
```json
{
  "name": "retail-store-checkout",
  "version": "1.0.0",  ← This is extracted
  "description": "Checkout service"
}
```

Command executed:
```groovy
def packageJson = readJSON file: "src/checkout/package.json"
version = packageJson.version
// Output: 1.0.0
```

**Why Automatic Version Detection?**:
- ✅ Single source of truth (no duplicate version files)
- ✅ No manual version updates in Jenkinsfile
- ✅ Semantic versioning compliance
- ✅ Reduces human error
- ✅ Audit trail through source control

---

### 3. dockerBuildPush.groovy

**Purpose**: Build Docker image and push to Docker Hub registry

**Implementation**:

```groovy
def call(Map config) {
    script {
        // Build Docker image
        sh """
            echo "🔨 Building Docker image..."
            cd src/${config.service}
            docker build -t ${env.IMAGE} .
        """
        
        // Login to Docker Hub
        withCredentials([usernamePassword(
            credentialsId: 'dockerhub-creds',
            usernameVariable: 'USER',
            passwordVariable: 'PASS'
        )]) {
            sh '''
                echo "🔐 Logging into Docker Hub..."
                echo $PASS | docker login -u $USER --password-stdin
            '''
        }
        
        // Push image
        sh """
            echo "📤 Pushing image to registry..."
            docker push ${env.IMAGE}
        """
        
        echo "✅ Image pushed: ${env.IMAGE}"
    }
}
```

**Build Process Details**:

1. **Docker Build**:
   ```bash
   cd src/cart
   docker build -t sarthak6700/retail-store-cart:1.0.0 .
   ```
   
   - Uses Dockerfile in service directory
   - Tags with full version
   - Multi-stage builds for optimization (if configured)

2. **Docker Login**:
   ```bash
   echo $DOCKER_PASSWORD | docker login -u $DOCKER_USER --password-stdin
   ```
   
   - Credentials from Jenkins credential store
   - Secure (password not exposed in logs)
   - Automatic logout in post-actions

3. **Docker Push**:
   ```bash
   docker push sarthak6700/retail-store-cart:1.0.0
   ```
   
   - Pushes to Docker Hub public registry
   - Available format: `<username>/retail-store-<service>:<version>`

**Image Tagging Strategy**:

```
Registry: docker.io (Docker Hub)
Repository: sarthak6700/retail-store-<service>
Tags:
  - <version>     (e.g., 1.0.0)    ← Primary tag (used in prod)
  - v<major>      (e.g., v1)       ← Major version alias
  - latest        (Not used)       ← Avoided for reproducibility
```

**Why This Approach?**:
- ✅ **Immutable tags**: Version-based tags never change
- ✅ **Reproducibility**: Can always rebuild exact version
- ✅ **Rollback support**: Previous versions always available
- ✅ **Security**: Credentials managed by Jenkins
- ✅ **Audit**: Clear image lineage

**Docker Build Optimization**:

Example multi-stage Dockerfile (Maven services):
```dockerfile
# Build stage
FROM maven:3.8-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Benefits:
- Smaller final image size
- Faster builds (layer caching)
- No build tools in production image

---

### 4. deployK8s.groovy

**Purpose**: Deploy service to Kubernetes using Helm

**Implementation**:

```groovy
def call(Map config) {
    sh """
        echo "🚀 Deploying ${config.service} version ${config.version} to ${config.namespace}"
        
        cd helm-repo/retail-store-helm-chart
        
        helm upgrade --install retail-store . \
            -n retail-store-${config.namespace} \
            --set retail-store-${config.service}.image.tag=${config.version} \
            -f values.yaml \
            -f values/${config.env}/values-${config.namespace}-${config.env}.yaml \
            --create-namespace \
            --wait \
            --timeout 5m
        
        echo "✅ Deployment complete!"
    """
}
```

**Deployment Process Breakdown**:

1. **Helm Upgrade/Install**:
   ```bash
   helm upgrade --install retail-store .
   ```
   - `upgrade --install`: Creates if doesn't exist, updates if exists
   - `retail-store`: Release name (same for all services)
   - `.`: Chart location (current directory)

2. **Namespace Management**:
   ```bash
   -n retail-store-prod
   --create-namespace
   ```
   - Deploys to environment-specific namespace
   - Auto-creates namespace if missing

3. **Version Override**:
   ```bash
   --set retail-store-cart.image.tag=1.0.0
   ```
   - Overrides image tag for specific service
   - Only updates changed service
   - Other services remain unchanged

4. **Values File Layering**:
   ```bash
   -f values.yaml
   -f values/eks/values-prod-eks.yaml
   ```
   - Base values first
   - Environment-specific values override
   - Layered configuration approach

5. **Wait for Readiness**:
   ```bash
   --wait --timeout 5m
   ```
   - Waits for pods to be ready
   - Fails deployment if timeout exceeded
   - Ensures service is healthy before marking success

**Helm Values Hierarchy**:

```
Priority (lowest to highest):
1. Chart default values (charts/<service>/values.yaml)
2. Umbrella chart values (values.yaml)
3. Environment values (values/eks/values-prod-eks.yaml)
4. Command-line overrides (--set retail-store-cart.image.tag=1.0.0)
```

**Example Deployment Commands**:

**Deploy Cart v1.0.0 to Production (EKS)**:
```bash
helm upgrade --install retail-store . \
  -n retail-store-prod \
  --set retail-store-cart.image.tag=1.0.0 \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml \
  --create-namespace
```

**Deploy Catalog v2.0.0 to Development (K3s)**:
```bash
helm upgrade --install retail-store . \
  -n retail-store-dev \
  --set retail-store-catalog.image.tag=2.0.0 \
  -f values.yaml \
  -f values/k3s/values-dev-k3s.yaml \
  --create-namespace
```

**Why Helm Over kubectl apply?**:
- ✅ **Atomic deployments**: All-or-nothing updates
- ✅ **Rollback capability**: Helm maintains release history
- ✅ **Templating**: Dynamic configuration based on environment
- ✅ **Dependency management**: Umbrella chart manages service dependencies
- ✅ **Release tracking**: `helm list` shows all deployments
- ✅ **Dry-run testing**: `helm template` previews changes

---

## 🔄 Pipeline Stages Deep Dive

### Stage 1: Detect Version

**Trigger**: Pipeline execution starts

**Execution Time**: ~5-10 seconds

**Activities**:
1. Parse source code for version
2. Extract version based on project type
3. Set environment variables (VERSION, IMAGE)
4. Log version information

**Output**:
```
✅ Version detected: 1.0.0
🐳 Docker image: sarthak6700/retail-store-cart:1.0.0
```

**Failure Scenarios**:
- Version not found in source file
- Invalid version format
- File parsing error

**Mitigation**:
- Validate version format (semver)
- Default to build number if version missing
- Clear error messages

---

### Stage 2: Build & Push Image

**Trigger**: Version detected successfully

**Execution Time**: ~2-10 minutes (depends on service)

**Activities**:
1. Navigate to service directory
2. Build Docker image from Dockerfile
3. Authenticate to Docker registry
4. Push image to registry
5. Logout from Docker

**Output**:
```
🔨 Building Docker image...
Step 1/8 : FROM maven:3.8-openjdk-17 AS build
Step 2/8 : WORKDIR /app
...
Successfully built abc123def456
Successfully tagged sarthak6700/retail-store-cart:1.0.0

🔐 Logging into Docker Hub...
Login Succeeded

📤 Pushing image to registry...
The push refers to repository [docker.io/sarthak6700/retail-store-cart]
1.0.0: digest: sha256:abc123... size: 2841
✅ Image pushed: sarthak6700/retail-store-cart:1.0.0
```

**Build Time Comparison**:
| Service  | Build Time | Image Size | Reason              |
|----------|------------|------------|---------------------|
| Cart     | ~5 min     | 350MB      | Maven dependencies  |
| Catalog  | ~2 min     | 20MB       | Go compiled binary  |
| Checkout | ~3 min     | 180MB      | Node modules        |
| Orders   | ~5 min     | 350MB      | Maven dependencies  |
| UI       | ~5 min     | 350MB      | Maven dependencies  |

**Optimization Techniques**:
1. **Layer Caching**: Docker caches unchanged layers
2. **Multi-stage Builds**: Smaller production images
3. **.dockerignore**: Exclude unnecessary files
4. **Parallel Builds**: Multiple services can build simultaneously

**Failure Scenarios**:
- Docker daemon not available
- Build errors (compilation, tests)
- Registry authentication failure
- Network issues during push

---

### Stage 3: Checkout Helm Repo

**Trigger**: Docker image pushed successfully

**Execution Time**: ~5-15 seconds

**Activities**:
1. Clone Helm chart repository
2. Navigate to umbrella chart directory
3. Verify chart structure

**Output**:
```
Cloning into 'helm-repo'...
remote: Enumerating objects: 500, done.
remote: Counting objects: 100% (500/500), done.
remote: Compressing objects: 100% (300/300), done.
Receiving objects: 100% (500/500), 150.00 KiB | 5.00 MiB/s, done.
```

**Why Separate Repo?**:
- ✅ **Separation of concerns**: App code vs infrastructure code
- ✅ **Different release cycles**: Charts update independently
- ✅ **GitOps ready**: ArgoCD can watch this repo
- ✅ **Reusability**: Charts can be used by multiple pipelines

**Failure Scenarios**:
- Repository not accessible
- Authentication failure
- Network issues

---

### Stage 4: Deploy to Kubernetes

**Trigger**: Helm repo checked out successfully

**Execution Time**: ~30-90 seconds

**Activities**:
1. Navigate to umbrella chart
2. Execute Helm upgrade command
3. Wait for deployment to complete
4. Verify pod readiness

**Output**:
```
🚀 Deploying cart version 1.0.0 to prod

Release "retail-store" has been upgraded. Happy Helming!
NAME: retail-store
LAST DEPLOYED: Mon Feb 03 10:30:00 2026
NAMESPACE: retail-store-prod
STATUS: deployed
REVISION: 15

NOTES:
Retail Store has been deployed!

✅ Deployment complete!
```

**Kubernetes Activities** (Behind the Scenes):

1. **Helm Processes Template**:
   ```
   values.yaml + values-prod-eks.yaml + --set flags
   → Rendered Kubernetes manifests
   ```

2. **kubectl Apply Equivalent**:
   ```yaml
   Deployment/cart-deployment  → Rolling update
   Service/cart                → No change (already exists)
   ConfigMap/cart-configmap    → Updated if changed
   Secret/cart-secret          → Updated if changed
   HPA/cart-hpa                → No change
   ServiceMonitor/cart-monitor → No change
   ```

3. **Rolling Update Process**:
   ```
   Old Pod (v0.9.0)  →  New Pod (v1.0.0)
   Running               Pending
   Running               ContainerCreating
   Running               Running (Health checks...)
   Running               Ready
   Terminating           Running (Traffic shifted)
   (Terminated)          Running
   ```

4. **Health Check Sequence**:
   ```
   Startup Probe (30 × 5s = 150s max)
       ↓ (passes)
   Liveness Probe (continuous every 10s)
       ↓ (passes)
   Readiness Probe (continuous every 5s)
       ↓ (passes)
   Traffic Enabled
   ```

**Deployment Strategies Supported**:

1. **Rolling Update** (Default):
   - Gradual replacement of old pods
   - Zero downtime
   - Automatic rollback on failure

2. **Blue-Green** (Via Helm):
   ```bash
   helm install retail-store-blue . -f values-blue.yaml
   # Test blue environment
   helm install retail-store-green . -f values-green.yaml
   # Switch traffic by updating service selector
   ```

3. **Canary** (Manual):
   ```bash
   # Deploy canary with 10% traffic
   helm upgrade --install retail-store-canary . \
     --set cart.replicaCount=1 \
     --set cart.image.tag=1.1.0-canary
   
   # Original deployment (90% traffic)
   helm upgrade --install retail-store . \
     --set cart.replicaCount=9 \
     --set cart.image.tag=1.0.0
   ```

**Failure Scenarios**:
- Helm chart syntax errors
- Kubernetes API unreachable
- Resource quota exceeded
- Image pull errors
- Health check failures
- Timeout waiting for readiness

**Automatic Rollback**:
```bash
# If deployment fails, Helm doesn't modify existing resources
# Manual rollback:
helm rollback retail-store <revision>
```

---

## 📦 Version Management Strategy

### Semantic Versioning (SemVer)

**Format**: `MAJOR.MINOR.PATCH`

**Rules**:
- **MAJOR**: Incompatible API changes
- **MINOR**: Backwards-compatible functionality
- **PATCH**: Backwards-compatible bug fixes

**Examples**:
- `1.0.0` → Initial release
- `1.0.1` → Bug fix
- `1.1.0` → New feature
- `2.0.0` → Breaking change

### Version Sources

**Maven Projects** (Cart, Orders, UI):
```xml
<version>1.0.0</version>
```

**Go Projects** (Catalog):
```go
// @version 1.0.0
```

**Node Projects** (Checkout):
```json
"version": "1.0.0"
```

### Version Update Workflow

1. **Developer updates version in source file**:
   ```bash
   # Maven
   mvn versions:set -DnewVersion=1.1.0
   
   # Node
   npm version 1.1.0
   
   # Go (manual edit)
   # Update // @version 1.1.0 in main.go
   ```

2. **Commit and push**:
   ```bash
   git add .
   git commit -m "Bump version to 1.1.0"
   git push origin main
   ```

3. **Pipeline automatically**:
   - Detects new version (1.1.0)
   - Builds image: `sarthak6700/retail-store-cart:1.1.0`
   - Deploys with new version

### Image Tag Strategy

**Used Tags**:
```
sarthak6700/retail-store-cart:1.0.0    ✅ (Version-specific)
sarthak6700/retail-store-cart:v1       ✅ (Major version alias)
```

**Avoided Tags**:
```
sarthak6700/retail-store-cart:latest   ❌ (Not reproducible)
sarthak6700/retail-store-cart:dev      ❌ (Mutable)
```

### Version History Tracking

**Helm Release History**:
```bash
# List all releases
helm list -n retail-store-prod

# Show release history
helm history retail-store -n retail-store-prod
```

Output:
```
REVISION  UPDATED                   STATUS      CHART               APP VERSION  DESCRIPTION
1         Mon Feb 01 10:00:00 2026  superseded  retail-store-1.0.0  1.0.0        Install complete
2         Mon Feb 01 11:00:00 2026  superseded  retail-store-1.0.0  1.0.1        Upgrade complete (cart)
3         Mon Feb 02 09:00:00 2026  deployed    retail-store-1.0.0  1.1.0        Upgrade complete (cart)
```

**Deployment Annotations**:
```yaml
annotations:
  deployment.kubernetes.io/revision: "3"
  app.version: "1.1.0"
  built.by: "jenkins"
  build.number: "42"
```

---

## 🐳 Docker Image Management

### Registry Structure

```
docker.io (Docker Hub)
└── sarthak6700/
    ├── retail-store-cart:1.0.0
    ├── retail-store-cart:1.0.1
    ├── retail-store-catalog:1.0.0
    ├── retail-store-checkout:1.0.0
    ├── retail-store-orders:1.0.0
    └── retail-store-ui:1.0.0
```

### Image Lifecycle

```
Developer commits code
    ↓
Pipeline builds image (1.0.1)
    ↓
Image pushed to registry
    ↓
Image deployed to K8s
    ↓
Old image (1.0.0) remains in registry
```

### Image Cleanup Strategy

**Retention Policy**:
- Keep last 10 versions per service
- Keep all versions from last 30 days
- Keep all production versions indefinitely

**Cleanup Script**:
```bash
# List all images
docker images sarthak6700/retail-store-cart

# Remove specific version
docker rmi sarthak6700/retail-store-cart:0.9.0

# Prune unused images on agent
docker image prune -a --filter "until=720h"  # 30 days
```

### Image Security

**Best Practices**:
1. **Scan images for vulnerabilities**:
   ```bash
   # Using Trivy
   trivy image sarthak6700/retail-store-cart:1.0.0
   ```

2. **Use minimal base images**:
   ```dockerfile
   FROM openjdk:17-jdk-slim  # ✅ Slim variant
   # vs
   FROM openjdk:17-jdk       # ❌ Full variant
   ```

3. **No secrets in images**:
   - Use environment variables
   - Use Kubernetes secrets
   - Use external secret managers

4. **Regular base image updates**:
   ```bash
   # Rebuild with updated base image
   docker build --no-cache --pull -t sarthak6700/retail-store-cart:1.0.1 .
   ```

---

## 🎛️ Helm Deployment Strategy

### Umbrella Chart Architecture

```
retail-store-helm-chart/
├── Chart.yaml                    # Umbrella chart definition
├── values.yaml                   # Base values (env-agnostic)
├── charts/                       # Subcharts
│   ├── cart/
│   ├── catalog/
│   ├── checkout/
│   ├── orders/
│   └── ui/
└── values/                       # Environment overrides
    ├── k3s/
    │   └── values-dev-k3s.yaml
    └── eks/
        └── values-prod-eks.yaml
```

### Deployment Process

**Step 1: Update Dependencies**
```bash
cd retail-store-helm-chart
helm dependency update

# This creates:
# charts/<service>-<version>.tgz
```

**Step 2: Template Rendering**
```bash
# Preview rendered manifests
helm template retail-store . \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml \
  --set retail-store-cart.image.tag=1.0.0
```

**Step 3: Deployment**
```bash
helm upgrade --install retail-store . \
  -n retail-store-prod \
  --set retail-store-cart.image.tag=1.0.0 \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml \
  --create-namespace
```

### Values Override Example

**Base values.yaml**:
```yaml
retail-store-cart:
  enabled: true
  image:
    repository: sarthak6700/retail-store-cart
    tag: latest  # ← Overridden by pipeline
```

**Environment values (values-prod-eks.yaml)**:
```yaml
retail-store-cart:
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: 500m
      memory: 1Gi
  aws:
    authMethod: irsa  # ← Production uses IRSA
```

**Pipeline override**:
```bash
--set retail-store-cart.image.tag=1.0.0  # ← Highest priority
```

**Final Rendered Value**:
```yaml
retail-store-cart:
  enabled: true
  image:
    repository: sarthak6700/retail-store-cart
    tag: 1.0.0  # ← From pipeline
  resources:
    requests:
      cpu: 200m   # ← From environment
      memory: 512Mi
  aws:
    authMethod: irsa  # ← From environment
```

### Selective Service Updates

**Update Only Cart Service**:
```bash
helm upgrade retail-store . \
  --set retail-store-cart.image.tag=1.1.0 \
  --reuse-values
```

**Update Multiple Services**:
```bash
helm upgrade retail-store . \
  --set retail-store-cart.image.tag=1.1.0 \
  --set retail-store-catalog.image.tag=2.0.0 \
  --reuse-values
```

### Helm Release Management

**List Releases**:
```bash
helm list -n retail-store-prod
```

**Get Release Details**:
```bash
helm get values retail-store -n retail-store-prod
helm get manifest retail-store -n retail-store-prod
```

**Release History**:
```bash
helm history retail-store -n retail-store-prod
```

---

## 🌍 Environment Management

### Environment Comparison

| Aspect                | Development (K3s)           | Production (EKS)            |
|-----------------------|-----------------------------|------------------------------|
| **Cluster**           | Single-node K3s             | Multi-node EKS              |
| **Namespace**         | retail-store-dev            | retail-store-prod           |
| **DynamoDB**          | Local pod                   | AWS DynamoDB                |
| **Authentication**    | Static credentials          | IRSA                        |
| **Storage**           | local-path                  | EBS CSI                     |
| **UI Service Type**   | NodePort (30080)            | LoadBalancer                |
| **Resource Limits**   | Lower (256Mi-512Mi)         | Higher (512Mi-1Gi)          |
| **Replicas**          | 1 per service               | 1-3 (HPA)                   |
| **Monitoring**        | Optional                    | Prometheus + Grafana        |
| **TLS**               | None                        | ALB with ACM                |

### Environment-Specific Values

**Development (values-dev-k3s.yaml)**:
```yaml
retail-store-cart:
  image:
    tag: v1
  aws:
    authMethod: static
  configmap:
    endpoint: http://dynamodb:8000
  secrets:
    accessKeyId: local
    secretAccessKey: local

retail-store-dynamodb:
  enabled: true  # ← Local DynamoDB pod

retail-store-ui:
  service:
    type: NodePort
    nodePort: 30080
```

**Production (values-prod-eks.yaml)**:
```yaml
retail-store-cart:
  image:
    tag: v1
  aws:
    authMethod: irsa
  serviceAccount:
    name: cart-sa
    roleArn: arn:aws:iam::123456789:role/cart-dynamodb-role

retail-store-dynamodb:
  enabled: false  # ← Use AWS DynamoDB

retail-store-ui:
  service:
    type: LoadBalancer
```

### Pipeline Environment Selection

**Deploy to Development**:
```groovy
microservicePipeline(
    service: "cart",
    type: "maven",
    namespace: "dev",   # ← Development namespace
    env: "k3s"          # ← K3s values
)
```

**Deploy to Production**:
```groovy
microservicePipeline(
    service: "cart",
    type: "maven",
    namespace: "prod",  # ← Production namespace
    env: "eks"          # ← EKS values
)
```

### Environment Promotion Workflow

```
Developer Branch → Dev Environment (K3s)
       ↓ (Testing)
Main Branch → Staging Environment (Optional)
       ↓ (QA Approval)
Tagged Release → Production (EKS)
```

**Manual Promotion**:
```bash
# Test in dev
helm upgrade retail-store . \
  -n retail-store-dev \
  -f values.yaml \
  -f values/k3s/values-dev-k3s.yaml

# Promote to prod (after testing)
helm upgrade retail-store . \
  -n retail-store-prod \
  -f values.yaml \
  -f values/eks/values-prod-eks.yaml
```

---

## 🔐 Security & Credentials

### Jenkins Credentials Management

**Stored Credentials**:
1. **dockerhub-creds**: Docker Hub username/token
2. **kubeconfig**: Kubernetes cluster access (if external)
3. **github-token**: GitHub API access (optional)

**Credential Types**:
```
Username with password → dockerhub-creds
Secret file → kubeconfig
Secret text → github-token
```

### Accessing Credentials in Pipeline

**Docker Hub**:
```groovy
withCredentials([usernamePassword(
    credentialsId: 'dockerhub-creds',
    usernameVariable: 'USER',
    passwordVariable: 'PASS'
)]) {
    sh 'echo $PASS | docker login -u $USER --password-stdin'
}
```

**Kubeconfig**:
```groovy
withCredentials([file(
    credentialsId: 'kubeconfig',
    variable: 'KUBECONFIG'
)]) {
    sh 'kubectl get pods'
}
```

### Kubernetes Secrets

**Creation**:
```bash
# Docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=docker.io \
  --docker-username=sarthak6700 \
  --docker-password=<token> \
  -n retail-store-prod

# Generic secret
kubectl create secret generic cart-secret \
  --from-literal=AWS_ACCESS_KEY_ID=xxx \
  --from-literal=AWS_SECRET_ACCESS_KEY=yyy \
  -n retail-store-dev
```

**Usage in Deployment**:
```yaml
envFrom:
- secretRef:
    name: cart-secret
```

### AWS IRSA (Production)

**Benefits**:
- ✅ No static credentials
- ✅ Automatic credential rotation
- ✅ Audit trail via CloudTrail
- ✅ Least privilege access

**Components**:
1. **EKS OIDC Provider**: Trust relationship with AWS IAM
2. **IAM Role**: Permissions to access DynamoDB
3. **Kubernetes ServiceAccount**: Annotated with IAM role ARN
4. **Pod**: Uses ServiceAccount

**How It Works**:
```
Pod starts with ServiceAccount
    ↓
Kubernetes injects OIDC token
    ↓
AWS SDK calls STS:AssumeRoleWithWebIdentity
    ↓
Receives temporary credentials (15min-12hr)
    ↓
Accesses DynamoDB with credentials
```

### Security Best Practices

1. **Never commit secrets to Git**:
   ```bash
   # .gitignore
   *.env
   secrets/
   kubeconfig
   ```

2. **Rotate credentials regularly**:
   ```bash
   # Generate new Docker Hub token quarterly
   # Update in Jenkins credentials
   ```

3. **Use least privilege**:
   ```json
   {
     "Effect": "Allow",
     "Action": ["dynamodb:GetItem", "dynamodb:PutItem"],
     "Resource": "arn:aws:dynamodb:*:*:table/Items"
   }
   ```

4. **Audit access**:
   ```bash
   # Check who accessed credentials
   kubectl logs deployment/jenkins -n jenkins | grep "dockerhub-creds"
   ```

5. **Encrypt at rest**:
   ```bash
   # Enable EKS secrets encryption
   aws eks update-cluster-config \
     --name retail-cluster \
     --encryption-config provider=aws-kms,key=<kms-key-arn>
   ```

---

## 🔄 Rollback Strategies

### Helm Rollback

**View History**:
```bash
helm history retail-store -n retail-store-prod
```

Output:
```
REVISION  UPDATED                   STATUS      DESCRIPTION
1         Mon Feb 01 10:00:00 2026  superseded  Install complete
2         Mon Feb 01 11:00:00 2026  superseded  Upgrade complete (cart v1.0.1)
3         Mon Feb 02 09:00:00 2026  deployed    Upgrade complete (cart v1.1.0)
```

**Rollback to Previous Version**:
```bash
helm rollback retail-store -n retail-store-prod

# Or specific revision
helm rollback retail-store 2 -n retail-store-prod
```

**What Happens**:
1. Helm reverts to revision 2 manifests
2. Kubernetes performs rolling update
3. New pods with v1.0.1 image start
4. Old pods with v1.1.0 terminate
5. Traffic shifts to v1.0.1 pods

### Kubernetes Rollback

**Using kubectl**:
```bash
# View deployment history
kubectl rollout history deployment/cart-deployment -n retail-store-prod

# Rollback to previous version
kubectl rollout undo deployment/cart-deployment -n retail-store-prod

# Rollback to specific revision
kubectl rollout undo deployment/cart-deployment --to-revision=2 -n retail-store-prod
```

### Pipeline Rollback

**Automated Rollback** (On Failure):
```groovy
pipeline {
    stages {
        stage('Deploy') {
            steps {
                deployK8s(config)
            }
        }
    }
    
    post {
        failure {
            script {
                echo "❌ Deployment failed - initiating rollback..."
                sh """
                    helm rollback retail-store -n retail-store-${namespace}
                """
            }
        }
    }
}
```

**Manual Rollback** (Re-run Pipeline):
```groovy
// Modify Jenkinsfile temporarily
microservicePipeline(
    service: "cart",
    type: "maven",
    namespace: "prod",
    env: "eks",
    version: "1.0.0"  // ← Force specific version
)
```

### Rollback Testing

**Pre-rollback Verification**:
```bash
# Check current version
kubectl get deployment cart-deployment -n retail-store-prod \
  -o jsonpath='{.spec.template.spec.containers[0].image}'

# Output: sarthak6700/retail-store-cart:1.1.0
```

**Post-rollback Verification**:
```bash
# Check new version
kubectl get deployment cart-deployment -n retail-store-prod \
  -o jsonpath='{.spec.template.spec.containers[0].image}'

# Output: sarthak6700/retail-store-cart:1.0.0

# Verify pods
kubectl get pods -n retail-store-prod -l app=cart

# Test endpoint
curl http://cart-service/health
```

### Rollback SLA

**Target Times**:
- Detection: < 5 minutes (monitoring alerts)
- Decision: < 2 minutes (runbook consultation)
- Execution: < 3 minutes (Helm rollback command)
- Verification: < 2 minutes (health checks)
- **Total**: < 12 minutes

---

## 🔄 Pipeline Execution Flow

### End-to-End Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. DEVELOPER ACTIVITY                                            │
│    - Developer commits code to GitHub                            │
│    - Version in source updated (e.g., 1.0.0 → 1.1.0)           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. JENKINS TRIGGER                                               │
│    - Webhook from GitHub (or manual trigger)                     │
│    - Jenkins detects changes in service directory                │
│    - Loads appropriate Jenkinsfile                               │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. PIPELINE INITIALIZATION                                       │
│    - Loads shared library (@Library('retail-lib'))              │
│    - Calls microservicePipeline with config                      │
│    - Allocates Jenkins agent (AGENT-1)                           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. STAGE: DETECT VERSION                                         │
│    - Execute detectVersion.groovy                                │
│    - Parse source file (pom.xml/main.go/package.json)          │
│    - Extract version (1.1.0)                                     │
│    - Set env.VERSION = 1.1.0                                     │
│    - Set env.IMAGE = sarthak6700/retail-store-cart:1.1.0       │
│    Output: ✅ Version detected: 1.1.0                           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. STAGE: BUILD & PUSH IMAGE                                     │
│    - Execute dockerBuildPush.groovy                              │
│    - cd src/cart                                                 │
│    - docker build -t sarthak6700/retail-store-cart:1.1.0 .     │
│    - docker login (using Jenkins credentials)                    │
│    - docker push sarthak6700/retail-store-cart:1.1.0           │
│    - docker logout                                               │
│    Output: ✅ Image pushed: ...cart:1.1.0                       │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. STAGE: CHECKOUT HELM REPO                                     │
│    - Clone https://github.com/.../retail-store-aws-deployment   │
│    - Navigate to helm-repo/retail-store-helm-chart              │
│    Output: ✅ Helm repo checked out                             │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 7. STAGE: DEPLOY TO KUBERNETES                                   │
│    - Execute deployK8s.groovy                                    │
│    - helm upgrade --install retail-store .                       │
│      -n retail-store-prod                                        │
│      --set retail-store-cart.image.tag=1.1.0                    │
│      -f values.yaml                                              │
│      -f values/eks/values-prod-eks.yaml                         │
│      --wait --timeout 5m                                         │
│    Output: ✅ Deployment complete!                              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 8. KUBERNETES DEPLOYMENT                                         │
│    - Helm renders templates                                      │
│    - kubectl applies manifests                                   │
│    - Rolling update starts:                                      │
│      * New pod (cart:1.1.0) created                             │
│      * Startup probe (30 × 5s)                                  │
│      * Liveness probe passes                                     │
│      * Readiness probe passes                                    │
│      * Pod marked Ready                                          │
│      * Traffic shifts to new pod                                 │
│      * Old pod (cart:1.0.0) terminates                          │
│    Output: Deployment successful                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 9. POST-ACTIONS                                                  │
│    - Docker logout                                               │
│    - Send notifications (if configured)                          │
│    - Update deployment status                                    │
│    Output: Pipeline completed in 5m 23s                         │
└─────────────────────────────────────────────────────────────────┘
```

### Timeline Example

**Cart Service Deployment (v1.0.0 → v1.1.0)**:

```
00:00:00  Pipeline triggered
00:00:05  Agent allocated
00:00:10  Detect Version stage started
00:00:15  Version detected: 1.1.0
00:00:20  Build & Push stage started
00:00:25  Docker build started
00:03:45  Docker build completed (3m 20s)
00:03:50  Docker login successful
00:04:10  Image pushed to registry (20s)
00:04:15  Docker logout
00:04:20  Checkout Helm Repo started
00:04:32  Helm repo cloned (12s)
00:04:35  Deploy stage started
00:04:40  Helm upgrade command executed
00:04:50  Kubernetes deployment started
00:05:00  New pod created
00:05:10  Container image pulled
00:05:30  Startup probe in progress
00:06:30  Startup probe passed (1m)
00:06:35  Liveness probe passed
00:06:40  Readiness probe passed
00:06:45  Pod marked Ready
00:06:50  Traffic shifted to new pod
00:07:00  Old pod terminated
00:07:05  Deployment marked successful
00:07:10  Pipeline completed

Total Time: 7m 10s
```

---

## 🔍 Troubleshooting CI/CD

### Common Issues and Solutions

#### Issue 1: Version Detection Fails

**Symptom**:
```
Error: Version not found in src/cart/pom.xml
```

**Causes**:
1. Invalid pom.xml format
2. Version tag missing
3. File path incorrect

**Debug**:
```bash
# Test version extraction locally
cd src/cart
mvn help:evaluate -Dexpression=project.version -q -DforceStdout
```

**Solution**:
```xml
<!-- Ensure version tag exists -->
<project>
    <version>1.0.0</version>
</project>
```

---

#### Issue 2: Docker Build Fails

**Symptom**:
```
Error: docker: command not found
```

**Causes**:
1. Docker not installed on agent
2. Jenkins user not in docker group
3. Docker daemon not running

**Debug**:
```bash
# On Jenkins agent
which docker
docker ps
sudo systemctl status docker
```

**Solution**:
```bash
# Add Jenkins user to docker group
sudo usermod -aG docker jenkins

# Restart Jenkins agent
sudo systemctl restart jenkins-agent
```

---

#### Issue 3: Docker Push Fails

**Symptom**:
```
Error: unauthorized: authentication required
```

**Causes**:
1. Invalid Docker Hub credentials
2. Credentials not configured in Jenkins
3. Token expired

**Debug**:
```bash
# Test Docker login manually
echo $DOCKER_PASSWORD | docker login -u $DOCKER_USER --password-stdin
```

**Solution**:
1. Generate new Docker Hub token
2. Update credentials in Jenkins:
   ```
   Manage Jenkins → Credentials → Update dockerhub-creds
   ```

---

#### Issue 4: Helm Deployment Fails

**Symptom**:
```
Error: release: not found
```

**Causes**:
1. Helm chart not found
2. Invalid chart path
3. Kubernetes API unreachable

**Debug**:
```bash
# Check Helm chart exists
ls -la helm-repo/retail-store-helm-chart

# Test Helm command
helm template retail-store . -f values.yaml

# Check kubectl access
kubectl get nodes
```

**Solution**:
```bash
# Update Helm dependencies
cd retail-store-helm-chart
helm dependency update

# Verify kubeconfig
export KUBECONFIG=/path/to/kubeconfig
kubectl get pods
```

---

#### Issue 5: Pod ImagePullBackOff

**Symptom**:
```
Pod status: ImagePullBackOff
Events: Failed to pull image "sarthak6700/retail-store-cart:1.1.0"
```

**Causes**:
1. Image doesn't exist in registry
2. Invalid image tag
3. Registry authentication required

**Debug**:
```bash
# Check if image exists
docker pull sarthak6700/retail-store-cart:1.1.0

# Check pod events
kubectl describe pod cart-deployment-xxx -n retail-store-prod
```

**Solution**:
```bash
# Verify image was pushed
docker images | grep retail-store-cart

# Re-push if needed
docker push sarthak6700/retail-store-cart:1.1.0

# Check deployment image reference
kubectl get deployment cart-deployment -n retail-store-prod \
  -o jsonpath='{.spec.template.spec.containers[0].image}'
```

---

#### Issue 6: Health Probe Failures

**Symptom**:
```
Pod status: CrashLoopBackOff
Readiness probe failed: HTTP probe failed with statuscode: 503
```

**Causes**:
1. Application not started
2. Database connection failure
3. Health endpoint misconfigured

**Debug**:
```bash
# Check pod logs
kubectl logs cart-deployment-xxx -n retail-store-prod

# Exec into pod
kubectl exec -it cart-deployment-xxx -n retail-store-prod -- /bin/sh

# Test health endpoint
curl localhost:8080/actuator/health
```

**Solution**:
```yaml
# Increase startup probe failure threshold
startupProbe:
  failureThreshold: 30  # ← Increase from 15
  periodSeconds: 5
```

---

#### Issue 7: Shared Library Not Found

**Symptom**:
```
Error: Library retail-lib not found
```

**Causes**:
1. Library not configured in Jenkins
2. Wrong library name
3. Repository access issues

**Debug**:
```
Manage Jenkins → System → Global Pipeline Libraries
Check: retail-lib configuration
```

**Solution**:
1. Configure library:
   ```
   Name: retail-lib
   Default version: main
   Retrieval: Modern SCM
   Git URL: https://github.com/.../retail-store-aws-deployment.git
   Library Path: vars/
   ```
2. Mark as trusted
3. Test with simple pipeline

---

#### Issue 8: Namespace Not Found

**Symptom**:
```
Error: namespace "retail-store-prod" not found
```

**Causes**:
1. Namespace not created
2. Wrong namespace name
3. Kubectl context incorrect

**Debug**:
```bash
# List namespaces
kubectl get namespaces

# Check current context
kubectl config current-context
```

**Solution**:
```bash
# Create namespace
kubectl create namespace retail-store-prod

# Or use --create-namespace in Helm
helm upgrade --install retail-store . \
  --create-namespace \
  -n retail-store-prod
```

---

### Debug Commands Reference

```bash
# Jenkins
kubectl logs deployment/jenkins -n jenkins --tail=100
kubectl exec -it deployment/jenkins -n jenkins -- bash

# Pipeline
# View console output in Jenkins UI

# Docker
docker images
docker ps -a
docker logs <container-id>

# Kubernetes
kubectl get pods -n retail-store-prod
kubectl describe pod <pod-name> -n retail-store-prod
kubectl logs <pod-name> -n retail-store-prod
kubectl logs <pod-name> --previous -n retail-store-prod

# Helm
helm list -n retail-store-prod
helm history retail-store -n retail-store-prod
helm get values retail-store -n retail-store-prod
helm get manifest retail-store -n retail-store-prod

# Deployment
kubectl rollout status deployment/cart-deployment -n retail-store-prod
kubectl rollout history deployment/cart-deployment -n retail-store-prod
kubectl get events -n retail-store-prod --sort-by='.lastTimestamp'
```

---

## ✅ Best Practices Implemented

### 1. DRY Principle

**Before** (Without Shared Library):
```
5 services × 200 lines of Jenkinsfile = 1000 lines of duplicate code
```

**After** (With Shared Library):
```
5 services × 10 lines + 1 shared library (200 lines) = 250 lines total
75% code reduction
```

### 2. Version as Single Source of Truth

- Version defined once in source code
- Automatically detected by pipeline
- No version duplication in Jenkinsfile
- Consistent across build, tag, and deploy

### 3. Immutable Infrastructure

- Every deployment creates new image with version tag
- Images never overwritten (no `:latest` in prod)
- Full deployment history via Helm
- Easy rollback to any previous version

### 4. Environment Separation

- Separate namespaces (retail-store-dev, retail-store-prod)
- Environment-specific values files
- No environment logic in application code
- Clear promotion path (dev → prod)

### 5. Security First

- Credentials in Jenkins credential store (not code)
- IRSA for AWS access (no static keys in prod)
- Docker logout after every build
- Least privilege IAM policies

### 6. Fail Fast

- Pipeline fails at first error
- No deployment if image build fails
- Health probes prevent bad deployments
- Automatic rollback on failures

### 7. Observability

- Detailed logging at each stage
- Version tracking in Helm releases
- Deployment annotations for audit trail
- Jenkins build history

### 8. Idempotency

- `helm upgrade --install` (idempotent)
- Can run pipeline multiple times safely
- No side effects from failed pipelines

### 9. Declarative Configuration

- Everything defined in code (GitOps ready)
- No manual kubectl commands
- Infrastructure as Code (Helm charts)
- Reproducible deployments

### 10. Automation

- Zero manual steps
- Automatic version detection
- Automatic deployment
- Self-healing (HPA, probes)

---

## 🚀 Advanced Topics

### 1. Multi-Branch Pipeline

**Purpose**: Separate pipelines for feature branches

**Configuration**:
```groovy
// Jenkinsfile
if (env.BRANCH_NAME == 'main') {
    // Deploy to production
    namespace = 'prod'
    env = 'eks'
} else {
    // Deploy to dev
    namespace = 'dev'
    env = 'k3s'
}

microservicePipeline(
    service: "cart",
    type: "maven",
    namespace: namespace,
    env: env
)
```

### 2. Parallel Builds

**Purpose**: Build multiple services simultaneously

**Implementation**:
```groovy
pipeline {
    stages {
        stage('Build All Services') {
            parallel {
                stage('Build Cart') {
                    steps {
                        build job: 'cart-pipeline'
                    }
                }
                stage('Build Catalog') {
                    steps {
                        build job: 'catalog-pipeline'
                    }
                }
                stage('Build Checkout') {
                    steps {
                        build job: 'checkout-pipeline'
                    }
                }
            }
        }
    }
}
```

### 3. Integration Testing

**Purpose**: Test service after deployment

**Implementation**:
```groovy
stage('Integration Tests') {
    steps {
        sh '''
            # Wait for service to be ready
            kubectl wait --for=condition=ready pod \
              -l app=cart -n retail-store-prod --timeout=300s
            
            # Run integration tests
            ./tests/integration/run-tests.sh
        '''
    }
}
```

### 4. Canary Deployments

**Purpose**: Gradual rollout with traffic splitting

**Implementation**:
```bash
# Deploy canary (10% of traffic)
helm upgrade --install retail-store-canary . \
  --set cart.replicaCount=1 \
  --set cart.image.tag=1.1.0-canary \
  -n retail-store-prod

# Monitor metrics
# If successful, promote canary to stable
helm upgrade --install retail-store . \
  --set cart.image.tag=1.1.0 \
  -n retail-store-prod
```

### 5. Slack Notifications

**Purpose**: Alert team on deployment status

**Implementation**:
```groovy
post {
    success {
        slackSend(
            color: 'good',
            message: "✅ ${env.SERVICE} ${env.VERSION} deployed to ${env.NAMESPACE}"
        )
    }
    failure {
        slackSend(
            color: 'danger',
            message: "❌ ${env.SERVICE} ${env.VERSION} deployment failed"
        )
    }
}
```

### 6. Approval Gates

**Purpose**: Manual approval before production

**Implementation**:
```groovy
stage('Deploy to Production') {
    when {
        branch 'main'
    }
    steps {
        input message: 'Deploy to production?', ok: 'Deploy'
        deployK8s(
            service: config.service,
            namespace: 'prod',
            env: 'eks'
        )
    }
}
```

### 7. ArgoCD Integration

**Purpose**: GitOps continuous deployment

**Configuration**:
```yaml
# argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: retail-store
spec:
  source:
    repoURL: https://github.com/.../retail-store-aws-deployment
    targetRevision: main
    path: retail-store-helm-chart
    helm:
      valueFiles:
      - values.yaml
      - values/eks/values-prod-eks.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: retail-store-prod
```

---

## 📚 Summary

This CI/CD pipeline provides:

✅ **Automated deployments** from commit to production
✅ **DRY code** with shared Jenkins library
✅ **Version management** from source code
✅ **Multi-environment support** (K3s dev, EKS prod)
✅ **Security** with credentials management and IRSA
✅ **Rollback capability** via Helm
✅ **Production-grade** practices and patterns

**Key Achievements**:
- 75% reduction in pipeline code
- <10 minute deployment time
- Zero manual intervention required
- Complete audit trail
- Easy rollback (< 2 minutes)

---

**For questions or support, refer to troubleshooting section or contact DevOps team.**