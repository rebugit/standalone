#!/usr/bin/env sh

set -e

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
NAMESPACE=rebugit

echo "Adding rebugit helm repository"
helm repo add rebugit https://charts.rebugit.com

echo "Deploying helm chart..."
helm upgrade -i rebugit -n rebugit rebugit/rebugit -f "$SCRIPT_PATH"/rebugit-values.yaml --create-namespace \
  --set postgresql.postgresqlPassword="$POSTGRES_PASSWORD" \
  --set postgresql.postgresqlUserPassword="$POSTGRES_USER_PASSWORD" \
  --set keycloak.auth.adminPassword="$KEYCLOAK_ADMIN_PASSWORD" \
  --set keycloak.auth.userName="$KEYCLOAK_USER_NAME" \
  --set keycloak.auth.userPassword="$KEYCLOAK_USER_PASSWORD"