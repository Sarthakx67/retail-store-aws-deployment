Good — now you’re asking the **right question**.

Below is **everything required**, in **correct order**, to APPLY the logic you already understand.
No hand-waving. No skipping. This is the **real, complete checklist** for local DynamoDB + cart in Kubernetes.

---

# 🎯 Goal

Run **cart service** in Kubernetes using **local DynamoDB** via **environment-based configuration**.

---

## 🧩 1. What components you MUST have (no more, no less)

### Infrastructure inside Kubernetes

1. **DynamoDB container (local)**
2. **Service for DynamoDB** (ClusterIP)
3. **Cart Deployment** (already exists)
4. **Cart Service** (already exists)

---

### Configuration pieces

5. **Environment variables for cart**
6. **AWS credentials (fake but valid)**
7. **Region configuration**
8. **Table auto-creation enabled**

---

## 🧩 2. DynamoDB Local (what it actually is)

Local DynamoDB is:

* A Java process
* Exposes **HTTP on port 8000**
* Needs **no real AWS account**
* Still requires AWS SDK credentials to exist

📌 Treat it like **any other backend container**.

---

## 🧩 3. Kubernetes objects you need (mapping)

| Requirement      | K8s Object              |
| ---------------- | ----------------------- |
| DynamoDB runtime | Deployment              |
| DynamoDB network | Service                 |
| App config       | Env vars                |
| Secrets          | Secret (or env for now) |
| Internal DNS     | Service name            |

---

## 🧩 4. Exact environment variables cart REQUIRES

From README + AWS SDK expectations:

### App-level (from README)

* `RETAIL_CART_PERSISTENCE_PROVIDER=dynamodb`
* `RETAIL_CART_PERSISTENCE_DYNAMODB_TABLE_NAME=Items`
* `RETAIL_CART_PERSISTENCE_DYNAMODB_ENDPOINT=http://<dynamodb-service>:8000`
* `RETAIL_CART_PERSISTENCE_DYNAMODB_CREATE_TABLE=true`
* `PORT=8080`

---

### AWS SDK–level (NOT in README but REQUIRED)

Even local DynamoDB needs these:

* `AWS_ACCESS_KEY_ID=fake`
* `AWS_SECRET_ACCESS_KEY=fake`
* `AWS_REGION=us-east-1`

📌 These do NOT need to be real.

---

## 🧩 5. Networking model (THIS MUST BE CLEAR)

### Inside the cluster

```
cart pod
   |
   |  http://dynamodb:8000
   v
dynamodb service
   |
   v
dynamodb pod
```

🚫 No localhost
🚫 No NodePort
🚫 No external access

---

## 🧩 6. DynamoDB Service DNS (how cart finds DB)

If your Service is named:

```
dynamodb
```

Then cart uses:

```
http://dynamodb:8000
```

If different namespace:

```
http://dynamodb.<namespace>.svc.cluster.local:8000
```

---

## 🧩 7. Persistence reality check (important)

### Local DynamoDB data:

* Lives **inside the pod**
* Lost if pod restarts
* OK for dev
* NOT OK for prod

You accept this **intentionally** right now.

---

## 🧩 8. What you do NOT need (don’t overcomplicate)

❌ PVC
❌ StatefulSet
❌ InitContainers
❌ Sidecars
❌ Config files
❌ Code changes

This app is **designed for config-only DB switching**.

---

## 🧪 9. How you verify it WORKS

### Step 1: Logs

```bash
kubectl logs deploy/cart-deployment -n retail-store
```

You should see:

* DynamoDB client initialized
* Table created (once)

---

### Step 2: Functional test

1. Add item to cart
2. Restart cart pod
3. Fetch cart again

If data persists → DB is working.

---

## 🧠 10. Failure modes you MUST recognize

| Symptom                                 | Meaning              |
| --------------------------------------- | -------------------- |
| App starts but cart empty after restart | DB not used          |
| Connection refused                      | Endpoint wrong       |
| Credential error                        | Missing AWS env vars |
| Table not found                         | Auto-create false    |

---

## 🧠 11. Mental model (lock this in)

> Kubernetes only runs things.
> The app decides behavior via ENV.
> DynamoDB Local behaves like AWS SDK expects.

If something breaks:

* Check **env vars**
* Check **service DNS**
* Check **logs**

---

## ✅ FINAL CHECKLIST (print this mentally)

* [ ] DynamoDB Deployment
* [ ] DynamoDB Service (ClusterIP)
* [ ] Cart env vars set
* [ ] AWS creds provided
* [ ] Endpoint overridden
* [ ] Table auto-create enabled
* [ ] Cart logs clean
* [ ] Data survives pod restart

---

You now have **full application-level clarity**.

### Next logical step (only one):

> “Now give me the exact Kubernetes YAML for local DynamoDB + cart env wiring.”

When you ask that, I’ll give you **production-clean manifests**, not hacks.
