#!/bin/bash

export USER=$1
export CLUSTER_CA=$(kubectl config view --raw -o json | jq -r '.clusters[] | select(.name == "'$(kubectl config current-context)'") | .cluster."certificate-authority-data"')
export CLUSTER_NAME=$(kubectl config view --minify -o jsonpath={.current-context})
export CLIENT_CERTIFICATE_DATA=$(kubectl get csr $1-csr -o jsonpath='{.status.certificate}')
export CLUSTER_ENDPOINT=$(kubectl config view --raw -o json | jq -r '.clusters[] | select(.name == "'$(kubectl config current-context)'") | .cluster."server"')
export CLIENT_KEY_DATA=$(cat "$2" | base64 | tr -d '\n')

cat kubeconfig.tpl.yml | envsubst > $3/kubeconfig.$1.yml

