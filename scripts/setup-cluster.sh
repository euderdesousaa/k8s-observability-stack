#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting infrastructure deployment..."

# 1. Create KinD cluster using your configuration
# This ensures the node mapping and ports are consistent with your notebook setup
kind create cluster --config k8s/kind-config.yaml --name k8s-observability

# 2. Add and update Helm repositories
echo "Updating Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 3. Create Namespaces
echo "Creating namespaces..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -

# 4. Deploy Prometheus Stack
# Installs Prometheus, Grafana, and Alertmanager with your 32101 NodePort and 1Gi memory limits
echo "Deploying Prometheus stack..."
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f helm/prometheus-stack/values.yaml

# 5. Deploy Loki (Single Binary Mode)
# Configures Loki with the filesystem storage and specific schema dates you defined
echo "Deploying Loki..."
helm upgrade --install loki grafana/loki \
  --namespace logging \
  -f helm/loki-stack/values.yaml

# 6. Deploy Promtail
# Collects logs from your nodes and sends them to the Loki service
echo "Deploying Promtail..."
helm upgrade --install promtail grafana/promtail \
  --namespace logging \
  -f helm/promtail/values.yaml

# 7. Apply Custom Prometheus Rules
# Deploys your NodeMemoryCritical and PodsInErrorState alerts
echo "Applying custom infrastructure alerts..."
kubectl apply -f k8s/alert/infrastructure-alerts.yaml

echo "Deployment complete. Run 'kubectl get pods -A' to check status."