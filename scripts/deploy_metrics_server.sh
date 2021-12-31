#!/usr/bin/env bash
export CHART_VERSION=$1

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --version $CHART_VERSION --install metrics-server metrics-server/metrics-server --values metrics-api/metrics-server-values.yaml
