# Microservices Observability on AWS EKS: Professional Implementation

This repository contains a full, "Excellent" tier implementation of an observability pipeline for the **Google Online Boutique** microservices running on **Amazon EKS**. 

---

## 🏗️ 1. Application Overview: The Google Online Boutique
The **Google Online Boutique** is a cloud-native, polyglot application consisting of 12 microservices. These services work together to simulate a production e-commerce platform:

| Service | Language | Description |
| :--- | :--- | :--- |
| **Frontend** | Go | The web UI that handles user requests and renders the store. |
| **CartService** | .NET | Managed shopping carts using Redis. |
| **PaymentService** | Node.js | Processes payments (mocked) and emits tracing. |
| **ProductCatalog** | Go | Provides product information from a JSON database. |
| **CurrencyService** | Node.js | Handles real-time currency conversion. |
| **ShippingService** | Go | Calculates shipping costs and tracks shipments. |
| **CheckoutService** | Go | Coordinates the final checkout process. |
| **AdService** | Java | Serves advertisements to the frontend. |
| **EmailService** | Python | Sends order confirmation emails (mocked). |
| **Recommendation** | Python | Provides product recommendations. |
| **Redis** | C++ | Low-latency data store for cart persists. |
| **LoadGenerator** | Python | Simulates user traffic to generate traces. |

---

## 📊 2. The Monitoring Stack: Three Pillars of Observability

We've implemented a robust, **OpenTelemetry-native** pipeline that feeds into the **Elastic Stack**. 

### **Pillar 1: Distributed Tracing (APM)**
- **Tier 1 (Agent):** `otel-agent` (DaemonSet) runs on every node. It enriches spans with local K8s metadata and forwards them to the Gateway.
- **Tier 2 (Gateway):** `otel-gateway` (Deployment) handles **Tail-Based Sampling** (100% Error capture / 10% Probabilistic capture), protecting your storage from being flooded by "healthy" traffic while never missing a bug.
- **Backend:** **Elastic APM Server (ECK)** receives OTLP data and indexes it into Elasticsearch.

### **Pillar 2: Real User Monitoring (RUM)**
- **User Experience:** The **Elastic RUM Agent** is injected into the HTML of the `frontend` using a **Kubernetes ConfigMap override**. 
- **Business Value:** It captures **Core Web Vitals** (LCP, FID, CLS) and correlates browser sessions with backend server traces, providing a complete "User-to-Database" journey.

### **Pillar 3: Infrastructure Monitoring**
- **Elastic Agent:** Deployed as a standalone DaemonSet. It provides deep visibility into:
    - **Kubernetes Cluster**: Node health, CPU/Mem usage, and pod status.
    - **Service Metrics**: Redis performance and NGINX metrics.
    - **Logs**: Centralized log collection with automated metadata enrichment.

---

## 🏛️ 3. Detailed Architecture & Data Flow

```mermaid
graph TD
    User["User Browser (RUM)"] -->|Public ELB| Frontend["Frontend (Go/HTML)"]
    
    subgraph "AWS EKS Cluster (3 Nodes)"
        direction TB
        
        subgraph "Boutique Namespace"
            Frontend -->|gRPC/HTTP| Services["Backend Services (.NET, Go, Python, Node.js)"]
        end
        
        subgraph "Observability Stack"
            Services -->|OTLP| OTelAgent["OTel Agent (DaemonSet)"]
            OTelAgent -->|OTLP| OTelGateway["OTel Gateway (Deployment)"]
            
            OTelGateway -->|OTLP/HTTPS| APMServer["Elastic APM Server (ECK)"]
            APMServer -->|Indexing| ES["Elasticsearch Cluster"]
        end
        
        subgraph "Infrastructure Monitoring"
            EAgent["Elastic Agent (DaemonSet)"] -->|Metrics/Logs| ES
        end
        
        ES -->|Storage| EBS["AWS EBS Volumes (GP3)"]
    end
    
    Kibana["Kibana UI"] -->|Visualization| ES
    APMServer -->|RUM Data| User
```

---

## 💻 4. Deployment Instructions

### **1. Infrastructure Foundations**
- **Cluster**: `eksctl create cluster -f infrastructure/eks-cluster.yaml`
- **ECK Operator**: `kubectl apply -f https://download.elastic.co/downloads/eck/2.11.1/operator.yaml`
- **Elastic Stack**: `kubectl apply -f elastic-stack.yaml`

### **2. Telemetry Pipeline**
- **OTel Agent**: `helm upgrade --install otel-agent open-telemetry/opentelemetry-collector -f otel-collector/values-agent.yaml`
- **OTel Gateway**: `helm upgrade --install otel-gateway open-telemetry/opentelemetry-collector -f otel-collector/values-gateway.yaml`

### **3. Application & RUM Patching**
- **Boutique**: `kubectl apply -f microservices-demo/release/kubernetes-manifests.yaml`
- **Instrumentation**: `kubectl apply -f infrastructure/patch-frontend-otel.yaml`
- **RUM Agent**: `kubectl apply -f infrastructure/header-rum.html` (via ConfigMap)

---

## 💡 5. Business Value (Interview Talking Points)
- **Unified Visibility:** One platform (Elastic) for logs, metrics, traces, and user experience.
- **Vendor-Neutral:** By using **OpenTelemetry**, the instrumentation is portable. No "vendor lock-in."
- **Efficiency:** Using **Spot Instances** and **OTel Tail-Sampling** significantly reduces cloud operational costs.
- **Reliability:** Built-in alerting (integrated via `kibana-alerts.ndjson`) provides proactive notifications for health drops (<90%) or high error rates (>5%).

---

## 📂 6. Documentation of Decisions
Please refer to [DECISIONS.md](file:///c:/Users/AWS%20Community%20Day/OneDrive/Documentos/MTN-Accessment/DECISIONS.md) for a deep dive into why specific architectural paths were chosen over others.
