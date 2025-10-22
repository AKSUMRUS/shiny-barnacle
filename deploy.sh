#!/bin/bash

set -e

GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

NAMESPACE="aksum"
IMAGE_NAME="muffin-wallet"
IMAGE_TAG="latest"

log_info "Creating namespace..."
kubectl apply -f k8s/namespace.yaml

log_info "Applying secrets and configmaps..."
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -f k8s/configmap.yaml

log_info "Creating TLS secret..."
kubectl create secret tls muffin-wallet-tls \
  --cert=certs/server-cert.pem \
  --key=certs/server-key.pem \
  -n ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

log_info "Deploying PostgreSQL..."
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml

log_info "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n ${NAMESPACE} --timeout=120s

log_info "Deploying Muffin Wallet application..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

log_info "Waiting for application to be ready..."
kubectl wait --for=condition=ready pod -l app=muffin-wallet -n ${NAMESPACE} --timeout=180s

log_info "Applying Ingress..."
kubectl apply -f k8s/ingress.yaml

log_info "Checking deployment status..."
kubectl get all -n ${NAMESPACE}

log_info "Deployment completed successfully!"
