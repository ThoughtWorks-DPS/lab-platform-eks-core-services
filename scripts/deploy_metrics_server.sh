#!/usr/bin/env bash
export CLUSTER=$1
export CHART_VERSION=$(cat $CLUSTER.auto.tfvars.json | jq -r .metrics_server_chart_vevrsion)

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --version $CHART_VERSION --install metrics-server metrics-server/metrics-server --values metrics-api/metrics-server-values.yaml
