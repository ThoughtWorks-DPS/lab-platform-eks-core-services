#!/usr/bin/env bash
set -e

# Add the Flagger chart.
helm repo add flagger https://flagger.app

# Get latest information about Flagger chart.
helm repo update

# Install the Flagger chart, Istio and Prometheus version
helm upgrade -i flagger flagger/flagger \
--namespace=istio-system \
--set crd.create=false \
--set meshProvider=istio \
--set metricsServer=http://prometheus:9090
