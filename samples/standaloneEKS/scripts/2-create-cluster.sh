#!/usr/bin/env sh

set -e

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

echo "Creating AWS EKS cluster...this might take a while"
eksctl create cluster -f "$SCRIPT_PATH"/cluster.yaml --kubeconfig "$HOME"/.kube/rebugit-eks

echo "Cluster created, your kube config located at $KUBECONFIG"
echo "Waiting for resources"
sleep 10