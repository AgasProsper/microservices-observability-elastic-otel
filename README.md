# Microservices Observability (Elastic + OTel)

This repository contains a professional-grade implementation of a Distributed Observability Stack. It demonstrates a complete observability and infrastructure monitoring solution using **OpenTelemetry** and the **Elastic Stack** (ECK).

The target application is the **Google Online Boutique** microservices running on a local Minikube cluster.

## 🏗️ Architectural Overview

- **Collector Topology**: OTel Gateway (Deployment) + OTel Agent (DaemonSet).
- **Traces**: 10% probabilistic sampling + 100% error sampling.
- **Microservices**: Fully instrumented Go (Frontend), .NET (Cart), and Node.js (Payment) services.
- **RUM**: Real User Monitoring injected via OTel/Elastic JS SDK.
- **Infra Monitoring**: Elastic Agent (DaemonSet) + Beats (Metricbeat for Redis/NGINX, Filebeat for Logs).

## 📂 Repository Structure

*   **/otel-collector**: Helm values for the Gateway/Agent topology.
*   **/microservices-demo**: Instrumented source code for the Boutique app.
*   **/rum**: Elastic RUM configuration for the frontend.
*   **/dashboards**: NDJSON files for Kibana (Service Health, RUM, Business Transactions).
*   **/infrastructure**: YAMLs for Elastic Agent, Beats, and Alerting Rules.
*   **/scripts**: Stability patches (Resource limits, node selectors, gRPC probes).
*   **/docs**: Architectural Decision Logs (`DECISIONS.md`).

## 🚀 Final Verification

1.  **Pod Health**: `kubectl get pods -A` (All services should be `1/1 Running`).
2.  **Traffic**: `loadgenerator` is active and generating realistic user flows.
3.  **Telemetry**: Traces and metrics are flowing into the Elastic APM Server.
4.  **Dashboards**: Import NDJSON files into Kibana to view live health metrics.
