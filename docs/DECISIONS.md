# Architectural Decision Log

This document records the architectural decisions made during the setup and implementation of the SRE Practical Assessment.

## 1. Environment Details
*   **Kubernetes Environment:** Minikube (2+ nodes as required).
*   **Observability Backend:** Elastic Stack (Elasticsearch, Kibana, APM).
*   **Application:** Google Online Boutique (polyglot microservices).

## 2. OpenTelemetry Collector Topology
*   **Decision:** Deploy OTel Collector in a Gateway + Agent (DaemonSet) topology.
*   **Rationale:** The DaemonSet provides node-level collection (acting as an agent on each node to receive traces from local pods and collect host metrics). The central Gateway provides cluster-level processing, tail-based sampling, and reliable export to the Elastic APM Server.

## 3. Services Chosen for Instrumentation
*   **`frontend` (Go):** HTTP middleware tracing and gRPC client call tracing.
*   **`cartservice` (C#):** .NET auto-instrumentation and Redis client tracking.
*   **`paymentservice` (Node.js):** Node.js auto-instrumentation and custom span creation.

## 4. Real User Monitoring (RUM)
*   **Decision:** To be decided (Elastic RUM Agent or OTel Web SDK). Will inject into the frontend service to capture Core Web Vitals and correlate with backend traces.

## 5. Infrastructure Monitoring
*   **Compute/VMs:** Elastic Agent or Metricbeat for system tracking.
*   **Databases:** Elastic Agent integrations or Metricbeat for Postgres and Redis.
*   **Network:** Filebeat to parse and ship CNI flow logs.
*   **Ingress:** NGINX metrics via Elastic Agent or Metricbeat.
