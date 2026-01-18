# 🧠 BIG PICTURE (FIRST, LOCK THIS IN)

Your **Cart service** wants to store data in **DynamoDB**.

There are **two totally different worlds**:

```
LOCAL DEV (K3s)           vs           PRODUCTION (EKS)
Fake DynamoDB Pod                       Real AWS DynamoDB
Static credentials                      IAM-based access (IRSA)
```

Same application code.
**Different infrastructure responsibilities.**

---

# PART 1 — WHAT HAPPENS IN K3s (LOCAL DEV)

Let’s start with the **easy one**, because it builds intuition.

---

## 🟢 K3s FLOW (LOCAL MACHINE)

### What exists

* Your laptop / VM
* K3s cluster
* DynamoDB **local** container
* Cart container

### What does NOT exist

* Real AWS DynamoDB
* IAM
* IRSA
* AWS permissions

---

## Step-by-step (K3s)

### Step 1️⃣ You run DynamoDB as a Pod

This is just a **container**, nothing more.

```text
amazon/dynamodb-local
```

It listens on:

```
http://dynamodb:8000
```

---

### Step 2️⃣ Cart points to DynamoDB local

In ConfigMap:

```yaml
RETAIL_CART_PERSISTENCE_DYNAMODB_ENDPOINT: http://dynamodb:8000
```

Your app thinks:

> “I am talking to DynamoDB”

But it’s actually fake.

---

### Step 3️⃣ You give fake AWS credentials

Because DynamoDB Local **expects credentials** (even fake ones):

```yaml
AWS_ACCESS_KEY_ID=local
AWS_SECRET_ACCESS_KEY=local
```

These do NOTHING.
They just satisfy the SDK.

---

### Step 4️⃣ Cart creates tables automatically

Local DynamoDB allows:

```yaml
RETAIL_CART_PERSISTENCE_DYNAMODB_CREATE_TABLE=true
```

So:

* Table is auto-created
* No AWS account involved
* No permissions needed

---

### ✅ Result (K3s)

```
Cart → DynamoDB Local → Local disk
```

Everything works **without AWS**.

---

# PART 2 — WHAT CHANGES IN EKS (THIS IS THE HARD PART)

Now we move to **real production**.

Here is the **single most important rule**:

> ❌ **EKS does NOT create AWS resources for you**
>
> ✅ **You must prepare AWS first**

---

# 🧠 EKS MENTAL MODEL (LOCK THIS IN)

In EKS:

```
Kubernetes runs pods
AWS controls permissions
```

Kubernetes **cannot** access DynamoDB by default.

---

# PART 3 — COMPLETE EKS SETUP (BEGINNER, STEP BY STEP)

We will go **slow and sequential**.

---

## STEP 0️⃣ What you need BEFORE starting

You must have:

* AWS account
* IAM permissions to create:

  * DynamoDB
  * IAM roles
  * EKS cluster
* An EKS cluster already created

(We assume EKS exists — cluster creation is a separate topic.)

---

## STEP 1️⃣ CREATE DYNAMODB TABLE (ABSOLUTELY REQUIRED)

Cart **cannot connect** unless the table exists.

### You must tell AWS:

> “I want a table for cart items.”

### Example

```
Table name: Items
Partition key: id (String)
Region: ap-south-1
```

Important rules:

* DynamoDB **does NOT auto-create tables**
* Table name must EXACTLY match your app config
* Region must match your cluster/app region

---

## STEP 2️⃣ UNDERSTAND IAM (VERY IMPORTANT)

IAM answers ONE question:

> **WHO is allowed to do WHAT on AWS?**

Your cart service needs permission to:

* Put items
* Get items
* Update items
* Delete items

Without permission → **AccessDenied error**

---

## STEP 3️⃣ CREATE IAM POLICY (WHAT CAN CART DO?)

This policy defines **actions**.

Example (conceptual):

```text
Allow:
- dynamodb:GetItem
- dynamodb:PutItem
- dynamodb:UpdateItem
- dynamodb:DeleteItem
- dynamodb:Query
- dynamodb:Scan
```

Resource:

```
Only this table: Items
```

🧠 This is **least privilege**.

---

## STEP 4️⃣ CREATE IAM ROLE (WHO IS CART?)

Now you create an **IAM Role**.

Think of a role as:

> “A digital identity for my cart service”

Example role name:

```
cart-dynamodb-role
```

This role:

* Has the policy you created
* Does NOTHING by itself
* Must be assumed by something

---

## STEP 5️⃣ CONNECT IAM ROLE TO EKS (OIDC – MOST CONFUSING PART)

EKS uses **OIDC (OpenID Connect)** to trust pods.

This allows AWS to verify:

> “This request came from THIS pod in THIS cluster”

You must:

* Enable OIDC provider for your EKS cluster (one-time setup)
* Create a **trust relationship** in IAM

Trust relationship says:

```
Only pods using ServiceAccount "cart-sa"
in namespace "retail-store-prod"
are allowed to assume this role
```

🧠 This is what prevents random pods from stealing permissions.

---

## STEP 6️⃣ CREATE KUBERNETES SERVICE ACCOUNT

Now we go back to Kubernetes.

You create a **ServiceAccount**:

```yaml
kind: ServiceAccount
metadata:
  name: cart-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/cart-dynamodb-role
```

This annotation is **the bridge**.

---

## STEP 7️⃣ ATTACH SERVICE ACCOUNT TO CART POD

In your Cart Deployment:

```yaml
spec:
  serviceAccountName: cart-sa
```

Now Kubernetes knows:

> “This pod runs as cart-sa”

---

## STEP 8️⃣ WHAT HAPPENS INTERNALLY (MAGIC EXPLAINED)

When Cart starts:

1. Kubernetes mounts a **temporary token** into the pod
2. AWS SDK detects the token
3. SDK calls AWS STS
4. AWS validates token via OIDC
5. AWS returns **temporary credentials**
6. SDK uses those creds automatically

🧠 **YOU NEVER SEE THE CREDENTIALS**

---

## STEP 9️⃣ WHAT YOU MUST REMOVE IN EKS

❌ DO NOT set:

```yaml
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

❌ DO NOT set:

```yaml
DYNAMODB_ENDPOINT
```

❌ DO NOT enable:

```yaml
CREATE_TABLE=true
```

---

## STEP 🔟 CART APPLICATION SIDE (IMPORTANT)

Your Cart app must:

* Use AWS SDK
* Use **default credential provider chain**
* Use region correctly

Good news:

> Most AWS SDKs already do this automatically.

---

# PART 4 — FINAL FLOWS (COMPARE SIDE BY SIDE)

## K3s Flow

```
Cart → http://dynamodb:8000 → DynamoDB Local Pod
```

## EKS Flow

```
Cart Pod
 ↓
ServiceAccount (cart-sa)
 ↓
IAM Role (cart-dynamodb-role)
 ↓
AWS DynamoDB (Items table)
```

---

# PART 5 — COMMON BEGINNER MISTAKES (VERY IMPORTANT)

❌ Forgetting to create DynamoDB table
❌ Creating IAM role but not attaching it to ServiceAccount
❌ Using static AWS keys in EKS
❌ Leaving DynamoDB local endpoint enabled in prod
❌ Wrong AWS region

---

# PART 6 — HOW TO DEBUG WHEN IT FAILS

### Error: `AccessDeniedException`

➡ IAM policy wrong or role not assumed

### Error: `ResourceNotFoundException`

➡ DynamoDB table does not exist

### Error: `Unable to locate credentials`

➡ ServiceAccount not attached or IRSA broken

---

# 🧠 FINAL ONE-SCREEN SUMMARY (MEMORIZE THIS)

```
K3s:
- DynamoDB is a pod
- Fake creds
- Auto table creation

EKS:
- DynamoDB is AWS service
- IAM Role (IRSA)
- Table must exist
```

---

# 🎯 INTERVIEW-READY ANSWER (USE THIS)

> *In EKS, a cart service connects to DynamoDB by using IAM Roles for Service Accounts. A DynamoDB table is created in AWS, an IAM role with least-privilege access is attached to a Kubernetes ServiceAccount, and the pod assumes that role automatically via OIDC without static credentials.*

---

## ✅ FINAL VERDICT

If you understand **every step above**, you are:

* No longer a beginner
* Ready to debug real EKS issues
* Ahead of most candidates
* Thinking like a platform engineer

---
