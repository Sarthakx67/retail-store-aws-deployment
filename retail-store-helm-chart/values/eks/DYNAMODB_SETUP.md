Below is the **complete, beginner-friendly DynamoDB setup**, **step by step**, **nothing skipped**, exactly how you would do it for **EKS + Cart service**.
Read it in order — each step depends on the previous one.

I’ll clearly mark **WHY** each step exists so it sticks in your mind.

---

# 🧠 What You Are Setting Up (First, Understand This)

Your **Cart service running in EKS** needs to talk to **Amazon DynamoDB** securely.

To make that happen, you must configure **three things in AWS**:

```
1. DynamoDB TABLE        → where data is stored
2. IAM POLICY            → what actions are allowed
3. IAM ROLE + IRSA       → who is allowed to do those actions
```

Kubernetes alone is **not enough**.

---

# STEP 0️⃣ Prerequisites (DO NOT SKIP)

You must already have:

* ✅ AWS account
* ✅ EKS cluster created
* ✅ kubectl access to the cluster
* ✅ Helm working
* ✅ AWS CLI configured (`aws sts get-caller-identity` works)

If any of these are missing → stop and fix them first.

---

# STEP 1️⃣ Create DynamoDB Table (MOST IMPORTANT)

👉 **EKS will NOT create this for you**

### 1. Go to AWS Console → DynamoDB → Tables → Create table

### 2. Fill these fields carefully

| Field         | Value                                   |
| ------------- | --------------------------------------- |
| Table name    | `Items`                                 |
| Partition key | `id`                                    |
| Key type      | String                                  |
| Billing mode  | On-demand                               |
| Region        | **SAME as EKS** (example: `ap-south-1`) |

⚠️ **Rules**

* Table name must **exactly match** your Cart config
* DynamoDB does **not auto-create tables** in production

✅ Click **Create table**

---

# STEP 2️⃣ Verify the Table Exists

Open the table → check:

* Status = **ACTIVE**
* Region = correct
* Primary key = `id (String)`

If this table does not exist → Cart will fail no matter what you do next.

---

# STEP 3️⃣ Create IAM Policy (WHAT CAN CART DO?)

Now you tell AWS:

> “Cart is allowed to read/write ONLY this table.”

### 1. Go to IAM → Policies → Create policy

### 2. Choose **JSON**

### 3. Paste this (replace region & account ID):

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
      "Resource": "arn:aws:dynamodb:ap-south-1:<ACCOUNT_ID>:table/Items"
    }
  ]
}
```

### 4. Click **Next**

### 5. Policy name:

```
cart-dynamodb-policy
```

### 6. Create policy

🧠 **Why this matters**

* DynamoDB is **private by default**
* No policy = AccessDenied error

---

# STEP 4️⃣ Enable OIDC Provider for EKS (ONE-TIME SETUP)

This allows AWS to **trust Kubernetes ServiceAccounts**.

### Check if already enabled

```bash
aws eks describe-cluster \
  --name <CLUSTER_NAME> \
  --query "cluster.identity.oidc.issuer"
```

If you see a URL → OIDC is enabled → continue
If not → enable it (usually one-time setup via console or eksctl)

🧠 **Why this matters**

> This is what allows IRSA to exist.

---

# STEP 5️⃣ Create IAM Role (WHO IS CART?)

Now we create a **role** that:

* Has the policy
* Can be assumed by Cart pods only

### 1. Go to IAM → Roles → Create role

### 2. Trusted entity → **Web identity**

### 3. Select:

* Identity provider: **EKS OIDC provider**
* Audience: `sts.amazonaws.com`

### 4. Attach policy:

```
cart-dynamodb-policy
```

### 5. Role name:

```
cart-dynamodb-role
```

### 6. Create role

---

# STEP 6️⃣ Configure Trust Relationship (CRITICAL)

Open the role → **Trust relationships** → Edit

Replace with (example):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/oidc.eks.ap-south-1.amazonaws.com/id/XXXX"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.ap-south-1.amazonaws.com/id/XXXX:sub": "system:serviceaccount:retail-store-prod:cart-sa"
        }
      }
    }
  ]
}
```

🧠 **This line is EVERYTHING**

```
system:serviceaccount:<NAMESPACE>:cart-sa
```

Only **that pod** can use this role.

---

# STEP 7️⃣ Create Kubernetes ServiceAccount

Now back to Kubernetes.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cart-sa
  namespace: retail-store-prod
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/cart-dynamodb-role
```

Apply it:

```bash
kubectl apply -f cart-sa.yaml
```

---

# STEP 8️⃣ Attach ServiceAccount to Cart Deployment

In your **Cart Deployment**:

```yaml
spec:
  serviceAccountName: cart-sa
```

This is mandatory.

---

# STEP 9️⃣ Remove ALL AWS Secrets from EKS

In **EKS**, you must NOT have:

❌ `AWS_ACCESS_KEY_ID`
❌ `AWS_SECRET_ACCESS_KEY`
❌ DynamoDB local endpoint
❌ `CREATE_TABLE=true`

Only keep:

```yaml
AWS_REGION=ap-south-1
TABLE_NAME=Items
```

---

# STEP 🔟 What Happens Automatically (MAGIC EXPLAINED)

When Cart Pod starts:

```
Pod
 ↓
ServiceAccount token
 ↓
AWS STS (OIDC)
 ↓
Temporary credentials
 ↓
DynamoDB
```

You never see credentials.
AWS SDK handles everything.

---

# STEP 1️⃣1️⃣ How to Verify It Works

Check logs of Cart:

```bash
kubectl logs deployment/cart-deployment -n retail-store-prod
```

If it works:

* No AccessDenied errors
* Items can be added/read

---

# COMMON FAILURES (AND WHY)

| Error                        | Meaning                     |
| ---------------------------- | --------------------------- |
| AccessDeniedException        | IAM policy / trust issue    |
| ResourceNotFoundException    | Table doesn’t exist         |
| Unable to locate credentials | IRSA broken                 |
| Connection refused           | Using local endpoint in EKS |

---

# 🧠 FINAL MENTAL MODEL (MEMORIZE)

```
K3s:
- DynamoDB is a Pod
- Fake creds
- Auto table creation

EKS:
- DynamoDB is AWS
- IAM Role (IRSA)
- Table must exist
```

---

# 🎯 Interview-Ready Answer

> *To connect a Cart service running on EKS with DynamoDB, we create the DynamoDB table, define an IAM policy with least-privilege access, attach it to an IAM role, and use IRSA so the Cart pod assumes the role securely without static credentials.*

---

## ✅ FINAL VERDICT

If you follow **all steps above**:

* Your Cart will connect to DynamoDB
* You will not expose secrets
* You are doing **real production-grade EKS**

If you want next, I can:

* Walk through **CLI-only setup**
* Show **how to debug IRSA failures**
* Add **VPC endpoints**
* Explain **why RDS is sometimes better**

Just say **next**.
