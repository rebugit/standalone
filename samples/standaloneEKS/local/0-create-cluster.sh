#!/usr/bin/env sh

# Deploy the setup in a kind cluster, this is only for testing, you might need to disable
# the AWS nginx loadbalancer

# Create kind cluster
kind create cluster --config=cluster.yaml

# Install nginx ingress
echo "Installing nginx ingress controller"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml &&
echo "Waiting for nginx resources to be ready"
sleep 30 &&
echo "Waiting for nginx ingress"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s &&

# Setup Linkerd
echo "Installing Linkerd"
linkerd check --pre &&
linkerd install | kubectl apply -f - &&
linkerd check &&
linkerd viz install | kubectl apply -f -
echo "Linkerd installed"