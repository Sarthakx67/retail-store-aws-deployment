# Startup lets the app start, Liveness keeps it alive, Readiness lets traffic in.
{{ define "ui.healthProbes" }}
startupProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  failureThreshold: 30 # it will let application start and prevent being killed 
  periodSeconds: 5

livenessProbe:
  httpGet:
    path: /actuator/health/liveness #it will constantly check if application is alive and working
    port: 8080
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /actuator/health/readiness # it will check if application is ready to serve or not to let traffic in
    port: 8080
  periodSeconds: 5
{{ end }}
# Startup = don’t kill yet
# Liveness = restart if dead
# Readiness = stop traffic