#!/usr/bin/env sh

set -e

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
NAMESPACE=rebugit

echo "Getting $AWS_SECRET_MANAGER_NAME secrets from secret manager"

CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id "$AWS_SECRET_MANAGER_NAME" | jq -r '.SecretString')
postgresqlPassword=$(echo "$CREDENTIALS" | jq -r '.POSTGRES_PASSWORD')
postgresqlUserPassword=$(echo "$CREDENTIALS" | jq -r '.POSTGRES_USER_PASSWORD')
adminPassword=$(echo "$CREDENTIALS" | jq -r '.KEYCLOAK_ADMIN_PASSWORD')
userName=$(echo "$CREDENTIALS" | jq -r '.KEYCLOAK_USER_NAME')
userPassword=$(echo "$CREDENTIALS" | jq -r '.KEYCLOAK_USER_PASSWORD')

echo "Secrets retrieved"
echo "Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE || #Skip if already exists

echo "Adding rebugit helm repository"
helm repo add rebugit https://charts.rebugit.com

echo "Deploying helm chart..."
helm upgrade -i rebugit -n rebugit rebugit/rebugit -f "$SCRIPT_PATH"/rebugit-values.yaml \
  --set postgresql.postgresqlPassword="$postgresqlPassword" \
  --set postgresql.postgresqlUserPassword="$postgresqlUserPassword" \
  --set keycloak.auth.adminPassword="$adminPassword" \
  --set keycloak.auth.userName="$userName" \
  --set keycloak.auth.userPassword="$userPassword"