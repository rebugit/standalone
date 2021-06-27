#!/usr/bin/env sh

set -e

VERSION=$(date +%s)
export ENV=dev
export AWS_PROFILE=rebugit-${ENV}
export PUBLIC_REPO=public.ecr.aws/g0o0x0q6
export IMAGE_NAME=keycloak
export IMAGE_URI=${IMAGE_NAME}:${VERSION}

aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${PUBLIC_REPO}

docker build -t "${IMAGE_URI}" .
docker tag "${IMAGE_URI}" ${PUBLIC_REPO}/"${IMAGE_URI}"
docker push ${PUBLIC_REPO}/"${IMAGE_URI}"
echo new image sha "${VERSION}"