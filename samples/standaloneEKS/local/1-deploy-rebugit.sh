#!/usr/bin/env sh

set -e

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NAMESPACE=rebugit
postgresqlPassword=3nMYsUU5R7
postgresqlUserPassword=SdtQMfMH2h
adminPassword=pXgXHCb5Gg
userName=email@example.com
userPassword=mypassword

echo "Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE ||

helm dependency update "$SCRIPT_PATH"/../../../helm/

echo "Deploying helm chart..."
helm upgrade -i rebugit -n rebugit "$SCRIPT_PATH"/../../../helm/ -f "$SCRIPT_PATH"/rebugit-values.yaml \
  --set postgresql.postgresqlPassword="$postgresqlPassword" \
  --set postgresql.postgresqlUserPassword="$postgresqlUserPassword" \
  --set keycloak.auth.adminPassword="$adminPassword" \
  --set keycloak.auth.userName="$userName" \
  --set keycloak.auth.userPassword="$userPassword"