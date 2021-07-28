#!/usr/bin/env sh

WORKLOADS="keycloak postgres migrator"
for word in $WORKLOADS
do
  IMAGE_URI=ecr.aws.public.com/${word}:1.0.0

  echo $IMAGE_URI

done