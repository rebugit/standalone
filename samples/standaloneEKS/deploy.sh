#!/usr/bin/env sh

find scripts/ -type f -iname "*.sh" -exec chmod +x {} \;
. ./scripts/0-setup-input.sh &&
./scripts/1-create-secrets.sh &&
./scripts/2-create-cluster.sh &&
./scripts/3-deploy-rebugit.sh