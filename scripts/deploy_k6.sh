#!/usr/bin/env bash
set -e

# Add the Grafana chart.
helm repo add grafana https://grafana.github.io/helm-charts

# Get latest information about Grafana chart.
helm repo update

# Install the k6 operator
helm upgrade -i k6-operator grafana/k6-operator
