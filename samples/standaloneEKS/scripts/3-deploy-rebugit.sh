#!/usr/bin/env sh

helm upgrade -i rebugit -n rebugit . -f values.yaml \
  --set rebugit.postgresql.postgresqlPassword="$POSTGRES_PASSWORD" \
  --set rebugit.postgresql.postgresqlUserPassword="$POSTGRES_USER_PASSWORD" \
  --set rebugit.keycloak.auth.adminPassword="$KEYCLOAK_ADMIN_PASSWORD" \
  --set rebugit.keycloak.auth.userName="$KEYCLOAK_USER_NAME" \
  --set rebugit.keycloak.auth.userPassword="$KEYCLOAK_USER_PASSWORD"
