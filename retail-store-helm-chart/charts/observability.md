# 📘 OBSERVABILITY NOTES — Retail Store Microservices Project

---

## 1️⃣ What Observability Really Means (Core Idea)

**Observability ≠ Monitoring**

* **Monitoring** tells you *that* something is wrong
* **Observability** tells you *why* it is wrong

### Formal definition (important for interviews)

> *Observability is the ability to understand the internal state of a system by examining its outputs.*

In your project, the **outputs** are:

* Metrics (Prometheus)
* Logs (application + Kubernetes)
* Traces (request flow across services)

---

## 2️⃣ The 3 Pillars of Observability (FOUNDATION)

Your project already supports **all three**.

### 🧱 Pillar 1 — Metrics (Prometheus + Grafana) ✅

Numeric time-series data:

* Request counts
* Error rates
* Latency
* CPU / Memory

📌 Used for:

* Dashboards
* Alerts
* Trend analysis

---

### 🧱 Pillar 2 — Logs (Kubernetes + App logs) ⚠️ (conceptually)

Event-based records:

* Errors
* Stack traces
* Business events

📌 Used for:

* Root cause analysis
* Debugging specific failures

> Even without ELK/Loki, **`kubectl logs` is already observability**.

---

### 🧱 Pillar 3 — Traces (OpenTelemetry) ✅ (catalog already has it)

Request journey across services:

```
UI → Cart → Catalog → Orders → DB
```

📌 Used for:

* Finding latency sources
* Understanding service dependencies

---

## 3️⃣ Observability Goals for YOUR Project

For **each service** (cart, catalog, checkout, orders, ui), you must be able to answer:

1. Is it reachable?
2. Is it receiving traffic?
3. Is it failing?
4. Is it slow?
5. Why is it slow/failing?

This maps directly to **metrics + logs + traces**.

---

## 4️⃣ Metrics Observability (DEEP DIVE)

### 4.1 Availability (Monitoring Availability, not User Availability)

#### Metric

```promql
up{service="catalog"}
```

#### What it tells you

* Can Prometheus scrape `/metrics`?
* Is ServiceMonitor + networking correct?

#### What it does NOT tell you

* Whether users are getting 500s
* Whether latency is high

📌 **Used to detect total blindness**, not business outages.

---

### 4.2 Traffic Observability (Demand)

#### Why traffic matters

Without traffic, latency and errors are meaningless.

#### Metrics by service type

**Spring Boot (cart, orders)**

```promql
sum(rate(http_server_requests_seconds_count[1m])) by (uri)
```

**Go (catalog)**

```promql
sum(rate(gin_requests_total[1m])) by (path)
```

#### What traffic tells you

* Load increase
* Sudden drop (routing failure)
* Baseline vs abnormal behavior

---

### 4.3 Error Observability (Correctness)

#### Why errors matter more than `up`

A service can be:

* UP
* receiving traffic
* but **failing every request**


#### How to interpret

* `< 1%` → normal
* `1–5%` → degradation
* `> 5%` → incident

📌 **Error rate defines availability from the user’s perspective.**

---

### 4.4 Latency Observability (User Experience)

Latency is what users *feel*.

#### Why averages are useless

* Average hides tail latency
* One slow user ≠ problem
* 5% slow users = problem

#### P95 Latency (Go example)

```promql
histogram_quantile(
  0.95,
  sum(rate(gin_request_duration_seconds_bucket[5m])) by (le, path)
)
```

#### Interpretation

* **P50** → normal user
* **P95** → bad experience users
* **P99** → worst-case / executive demo failure

📌 **SLOs are always defined on P95/P99.**

---

## 5️⃣ Kubernetes Observability (WHY apps misbehave)

Sometimes the app is innocent.

---

### 5.1 Pod Restarts (Stability)

```promql
increase(kube_pod_container_status_restarts_total[15m])
```

#### Why important

* Restarts cause:

  * cold starts
  * cache loss
  * latency spikes

---

### 5.2 CPU Throttling (Hidden Killer)

```promql 
rate(container_cpu_cfs_throttled_seconds_total[5m])
```

#### Why critical

* App shows:

  * no errors
  * low CPU usage
* But kernel is **throttling execution**

📌 This explains “random slowness”.

---

### 5.3 Memory Pressure

```promql
container_memory_working_set_bytes
```

#### Why important

* Near limit → GC storms
* Over limit → OOMKill → pod restart

---

## 6️⃣ Correlation = Real Observability

Observability is **connecting signals**, not staring at graphs.

### Example: “Checkout is slow”

You correlate:

| Signal         | Observation |
| -------------- | ----------- |
| up             | 1           |
| Traffic        | High        |
| Errors         | Low         |
| P95 latency    | High        |
| CPU throttling | High        |

### Conclusion

👉 Not a bug
👉 Resource starvation
👉 Fix: increase CPU / HPA

This is **production-grade reasoning**.

---

## 7️⃣ Traces Observability (Request Flow)

Your catalog already uses **OpenTelemetry**.

### What traces show

* Which service is slow
* Which dependency dominates latency
* Where retries happen

### Example trace insight

```
UI (20ms)
 └── Checkout (40ms)
     └── Orders (800ms)  ❌
         └── DB (780ms)
```

Conclusion:
👉 Orders DB is bottleneck, not UI.

---

## 8️⃣ Logs Observability (Event Context)

Metrics tell **what**
Logs tell **why**

### Examples

* DB connection errors
* Validation failures
* Panic / stack traces

Even without ELK:

```bash
kubectl logs deployment/catalog
```

is observability.

---

## 9️⃣ Dashboards Strategy (IMPORTANT)

### One dashboard per service

Each dashboard MUST contain only:

1. Availability (`up`)
2. Request rate
3. Error rate
4. P95 latency
5. CPU
6. Memory
7. Pod restarts

❌ Do NOT add random panels
❌ Do NOT chase pretty graphs

---

## 🔔 Alerts (Observability → Action)

Alerts exist so humans **don’t watch Grafana**.

### Examples

* Error rate > 5% for 5 min
* P95 latency > SLA
* Pod restarts > 3 in 10 min
* CPU throttling > 20%

📌 Alerts answer: *“Should I wake up?”*

---

## 🎓 FINAL OBSERVABILITY SUMMARY 

> Monitoring tells me **something is wrong**.
> Observability tells me **why it’s wrong and how to fix it**.

Your project demonstrates:

* Metrics instrumentation
* Kubernetes observability
* Service-level reasoning
* Production debugging mindset

---

## 🚀 NEXT STEPS (RECOMMENDED)

1. Build **Checkout Service Dashboard**
2. Define **SLOs** (P95 latency, error rate)
3. Simulate failures (DB down, CPU pressure)
4. Explain graphs **out loud** like an incident review

