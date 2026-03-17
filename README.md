# MTN SRE Practical Assessment

This repository contains the configuration and implementation for the MTN SRE Practical Assessment, focusing on deploying an observability and infrastructure monitoring stack using **OpenTelemetry** and the **Elastic Stack**. 

The target application is the **Google Online Boutique** microservices running on a local Minikube cluster.

## Repository Structure

*   **/otel-collector**: Helm values and configs for the OpenTelemetry Collector Gateway & Agent topology.
*   **/instrumentation**: Code and manifest modifications for instrumenting the `frontend`, `cartservice`, and `paymentservice`.
*   **/rum**: Browser SDK integration for Real User Monitoring.
*   **/dashboards**: Exported Kibana Saved Objects containing operational dashboards.
*   **/infrastructure**: Elastic Agent/Beat configurations and exported Kibana Alerting Rules for comprehensive infrastructure monitoring.
*   **/docs**: Architectural decision logs (`DECISIONS.md`).

## Setup Instructions

*(To be populated as implementation proceeds)*
