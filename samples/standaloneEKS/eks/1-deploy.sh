#!/usr/bin/env sh

export KUBECONFIG=$HOME/.kube/rebugit-eks

helm upgrade -i rebugit -n rebugit . -f values.yaml
