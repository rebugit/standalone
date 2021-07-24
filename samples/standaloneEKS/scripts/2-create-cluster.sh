#!/usr/bin/env sh

echo "Creating AWS EKS cluster...this might take a while"
eksctl create cluster -f cluster.yaml --kubeconfig "$HOME"/.kube/rebugit-eks

echo "Cluster created, your kube config located at $KUBECONFIG"
echo "Waiting for resources"
sleep 10