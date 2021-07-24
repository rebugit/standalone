#!/usr/bin/env sh

echo "Creating secrets in AWS Secret manager..."
secrets_json=$( jq -n \
                  --arg pg_password "$POSTGRES_PASSWORD" \
                  --arg pg_user_password "$POSTGRES_USER_PASSWORD" \
                  --arg keycloak_admin_password "$KEYCLOAK_ADMIN_PASSWORD" \
                  --arg keycloak_user_password "$KEYCLOAK_USER_PASSWORD" \
                  --arg keycloak_user_name "$KEYCLOAK_USER_NAME" \
                  '{POSTGRES_PASSWORD: $pg_password, POSTGRES_USER_PASSWORD: $pg_user_password, KEYCLOAK_ADMIN_PASSWORD: $keycloak_admin_password, KEYCLOAK_USER_PASSWORD: $keycloak_user_password, KEYCLOAK_USER_NAME: keycloak_user_name }' )

aws secretsmanager create-secret --name "$AWS_SECRET_MANAGER_NAME" \
    --description "Rebugit Postgres and Keycloak secrets" \
    --secret-string "$secrets_json" >> /dev/null

echo "Secrets created"