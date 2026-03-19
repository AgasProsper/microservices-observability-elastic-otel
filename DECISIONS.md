# Architectural Decisions - Microservices Observability

This document outlines the key technical decisions made during the deployment of the observability stack on AWS EKS.

## 1. OpenTelemetry Topology (Agent/Gateway)
- **Decision**: Implemented a two-tier collector architecture (DaemonSet Agent + Deployment Gateway).
- **Rationale**: 
    - The **Agent** runs on every node to provide low-latency ingestion and host-level resource enrichment (`k8sattributes`). 
    - The **Gateway** acts as a centralized brain for heavy lifting: it aggregates signals from all agents, applies advanced `tail_sampling`, and manages the secure OTLP export to the Elastic APM Server.
- **Trade-off**: Slightly higher resource overhead but significantly better scalability and control over data signal volume.

## 2. Sampling Strategy
- **Decision**: 10% Probabilistic Sampling + 100% Error Sampling.
- **Rationale**: 
    - **10% Probabilistic**: Provides a statistically significant view of successful traces without overwhelming the APM server or ballooning storage costs.
    - **100% Error Sampling**: Ensures every single failed transaction is captured for root cause analysis (RCA), which is critical for meeting SLA/SLO requirements.
- **Implementation**: Handled at the **Gateway** level using the `tail_sampling` processor.

## 3. Real User Monitoring (RUM)
- **Decision**: Injected the Elastic RUM JS Agent via Kubernetes ConfigMap overrides.
- **Rationale**: Allowed for fast iteration and instrumentation of the Google Online Boutique `frontend` without requiring a full Docker image rebuild/push cycle in the assessment environment.
- **Trace Correlation**: Configured `distributedTracingOrigins` to ensure browser-to-backend spans share the same `trace_id`.

## 4. Infrastructure Monitoring
- **Decision**: Used Standalone Elastic Agent instead of Fleet-managed.
- **Rationale**: In a single-cluster assessment environment, a standalone agent with local YAML configuration reduces the moving parts (no need for a highly available Fleet Server deployment) while providing the same 4-signal coverage (NGINX, Redis, K8s, APM).

## 5. Security & Connectivity
- **Decision**: Switched APM Server to `LoadBalancer` type for RUM access.
- **Rationale**: Browser-side RUM agents require a public endpoint. While an Ingress is preferred for production, a dedicated LoadBalancer was chosen for maximum compatibility and simplicity in this EKS setup.
