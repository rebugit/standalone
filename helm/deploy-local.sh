#!/usr/bin/env sh

helm package -n rebugit . &&
mv rebugit-0.1.0.tgz ../samples/standaloneEKS/helm/charts/rebugit-0.1.0.tgz &&
cd ../samples/standaloneEKS/helm/ && helm dependency update