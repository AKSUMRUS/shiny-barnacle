#!/bin/bash

set -e

GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

NAMESPACE="aksum"
kubectl delete -f k8s/ingress.yaml --ignore-not-found=true
kubectl delete -f k8s/service.yaml --ignore-not-found=true
kubectl delete -f k8s/deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/postgres-service.yaml --ignore-not-found=true
kubectl delete -f k8s/postgres-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/postgres-pvc.yaml --ignore-not-found=true
kubectl delete -f k8s/configmap.yaml --ignore-not-found=true
kubectl delete -f k8s/postgres-secret.yaml --ignore-not-found=true
kubectl delete secret muffin-wallet-tls -n ${NAMESPACE} --ignore-not-found=true

kubectl delete namespace ${NAMESPACE} --ignore-not-found=true

log_info "Cleanup completed!"
