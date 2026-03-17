#!/bin/bash
# Patch instrumented deployments so that locally-built images are used
# and tracing + COLLECTOR_SERVICE_ADDR are set.
set -e

NAMESPACE=boutique
COLLECTOR_ADDR="opentelemetry-collector-agent.default.svc.cluster.local:4317"

for svc in frontend cartservice paymentservice; do
  echo "--- Patching $svc ---"

  # Set imagePullPolicy to Never so Minikube uses the locally built image
  minikube kubectl -- set image deployment/$svc server=${svc}:dev -n $NAMESPACE
  minikube kubectl -- patch deployment $svc -n $NAMESPACE \
    --type=strategic \
    -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"server\",\"imagePullPolicy\":\"Never\"}]}}}}"

done

# Enable tracing and set collector addr for frontend
minikube kubectl -- set env deployment/frontend -n $NAMESPACE \
  ENABLE_TRACING=1 \
  COLLECTOR_SERVICE_ADDR=$COLLECTOR_ADDR

# Enable tracing for paymentservice
minikube kubectl -- set env deployment/paymentservice -n $NAMESPACE \
  ENABLE_TRACING=1 \
  COLLECTOR_SERVICE_ADDR=$COLLECTOR_ADDR

# Set OTel endpoint for cartservice (it reads from env)
minikube kubectl -- set env deployment/cartservice -n $NAMESPACE \
  OTEL_EXPORTER_OTLP_ENDPOINT="http://$COLLECTOR_ADDR"

echo "All patches applied!"
minikube kubectl -- get pods -n $NAMESPACE
