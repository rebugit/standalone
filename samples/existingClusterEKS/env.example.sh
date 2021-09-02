#!/usr/bin/env sh

export AWS_REGION=""
export AWS_PROFILE=""
export AWS_TERRAFORM_STATE_BUCKET=""
export CLUSTER_NAME=""
export NAMESPACE=""
export KUBECONFIG=""

# If you are using Secret Manager
CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id "rebugit/secrets" | jq -r '.SecretString')
export POSTGRES_PASSWORD=$(echo "$CREDENTIALS" | jq -r '.POSTGRES_PASSWORD')
export POSTGRES_USER_PASSWORD=$(echo "$CREDENTIALS" | jq -r '.POSTGRES_USER_PASSWORD')
export KEYCLOAK_ADMIN_PASSWORD=$(echo "$CREDENTIALS" | jq -r '.KEYCLOAK_ADMIN_PASSWORD')
export KEYCLOAK_USER_NAME=$(echo "$CREDENTIALS" | jq -r '.KEYCLOAK_USER_NAME')
export KEYCLOAK_USER_PASSWORD=$(echo "$CREDENTIALS" | jq -r '.KEYCLOAK_USER_PASSWORD')
export REBUGIT_API_KEY=$(echo "$CREDENTIALS" | jq -r '.REBUGIT_API_KEY')