/**
 * Elastic RUM Configuration for the Online Boutique Frontend
 *
 * This file documents the RUM configuration injected into frontend/templates/header.html
 * It initializes the Elastic APM RUM agent to capture page load times,
 * user interactions, and correlates browser-side traces with backend APM traces.
 *
 * The agent is loaded inline via CDN so it fires before any app code.
 */

elasticApm.init({
  // The name shown in Kibana APM -> Services
  serviceName: 'frontend-browser',

  // Elastic APM Server endpoint (port-forwarded or via Ingress)
  // In production this should be the public APM Server URL
  serverUrl: process.env.ELASTIC_APM_SERVER_URL || 'http://apm-server:8200',

  // Allows correlating browser errors/transactions with service version
  serviceVersion: '1.0.0',

  // Labels all RUM data in Kibana with this environment
  environment: 'production',

  // Enable distributed tracing correlation with backend services
  distributedTracingOrigins: ['http://localhost:8080', 'http://frontend'],

  // Sample 20% of page loads to reduce noise
  transactionSampleRate: 0.2,
});
