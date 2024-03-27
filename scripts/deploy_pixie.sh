#!/usr/bin/env bash
set -e

export CLUSTER=$1
export PIXIE_DEPLOYMENT_KEY=$(cat $CLUSTER.auto.tfvars.json | jq -r .pixie_deploy_key)

echo "CLUSTER $CLUSTER"

# Add the Pixie operator chart.
helm repo add pixie-operator https://artifacts.px.dev/helm_charts/operator

# Get latest information about Pixie chart.
helm repo update

# Install the Pixie chart (No OLM present on cluster).
helm upgrade -i pixie pixie-operator/pixie-operator-chart \
  --set deployKey=$PIXIE_DEPLOYMENT_KEY \
  --set clusterName=$CLUSTER \
  --namespace pl \
  --create-namespace 
