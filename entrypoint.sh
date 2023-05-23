#!/usr/bin/env sh

SWAGGER_URL=$1
SERVICE=$2

curl "${SWAGGER_URL}" | linkerd profile --open-api - "${SERVICE}" | kubectl apply -f -