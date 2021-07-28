#!/usr/bin/env sh

# Temporary CLI

current_region=$(aws configure get region --profile="$AWS_PROFILE")
current_profile=${AWS_PROFILE:-default}

echo "AWS options"
echo "Input your AWS profile, current $current_profile"
read -r AWS_PROFILE
AWS_PROFILE=${AWS_PROFILE:-$current_profile}

echo "Input your AWS region (default $current_region)"
read -r AWS_REGION
AWS_REGION=${AWS_REGION:-$current_region}

echo "Profile set to: $AWS_PROFILE"
echo "Region set to: $AWS_REGION"

stty -echo
echo "Password will be managed by Secret manager"
echo "Input Postgres admin password"
read -r POSTGRES_PASSWORD

echo "Input Postgres user password"
read -r POSTGRES_USER_PASSWORD

echo "Input Keycloak admin password"
read -r KEYCLOAK_ADMIN_PASSWORD

echo "Input Keycloak user password"
read -r KEYCLOAK_USER_PASSWORD
stty echo

echo "Input Keycloak user username"
read -r KEYCLOAK_USER_NAME

export POSTGRES_PASSWORD=$POSTGRES_PASSWORD
export POSTGRES_USER_PASSWORD=$POSTGRES_USER_PASSWORD
export KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_ADMIN_PASSWORD
export KEYCLOAK_USER_PASSWORD=$KEYCLOAK_USER_PASSWORD
export KEYCLOAK_USER_NAME=$KEYCLOAK_USER_NAME

export AWS_REGION=$AWS_REGION
export AWS_PROFILE=AWS_PROFILE
export AWS_SECRET_MANAGER_NAME=rebugit/secrets

export KUBECONFIG=$HOME/.kube/rebugit-eks
