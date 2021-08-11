echo "Getting $AWS_SECRET_MANAGER_NAME secrets from secret manager"

CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id "$AWS_SECRET_MANAGER_NAME" | jq -r '.SecretString')
export POSTGRES_PASSWORD=$(echo "$CREDENTIALS" | jq -r '.POSTGRES_PASSWORD')
export POSTGRES_USER_PASSWORD=$(echo "$CREDENTIALS" | jq -r '.POSTGRES_USER_PASSWORD')
export KEYCLOAK_ADMIN_PASSWORD=$(echo "$CREDENTIALS" | jq -r '.KEYCLOAK_ADMIN_PASSWORD')
export KEYCLOAK_USER_NAME=$(echo "$CREDENTIALS" | jq -r '.KEYCLOAK_USER_NAME')
export KEYCLOAK_USER_PASSWORD=$(echo "$CREDENTIALS" | jq -r '.KEYCLOAK_USER_PASSWORD')

echo "Secrets retrieved"