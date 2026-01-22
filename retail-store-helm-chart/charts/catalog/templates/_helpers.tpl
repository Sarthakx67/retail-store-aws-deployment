{{ define "catalog.healthProbes" }}
startupProbe:
  httpGet:
    path: /health
    port: 8080
  failureThreshold: 40
  periodSeconds: 5

livenessProbe:
  httpGet:
    path: /health
    port: 8080
  periodSeconds: 10

readinessProbe:
  tcpSocket:
    port: 8080
  periodSeconds: 5
{{ end }}
# Use TCP for readiness.
# Why?
# No separate readiness endpoint
# /health is applevel only
# DB issues should stop traffic, not restart pod