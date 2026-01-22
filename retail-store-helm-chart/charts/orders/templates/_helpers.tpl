# Startup lets the app start, Liveness keeps it alive, Readiness lets traffic in.
{{ define "orders.healthProbes" }}
startupProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  failureThreshold: 30
  periodSeconds: 5

livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  periodSeconds: 5
{{ end }}

# Startup = don’t kill yet
# Liveness = restart if dead
# Readiness = stop traffic