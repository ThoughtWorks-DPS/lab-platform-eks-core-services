#!/usr/bin/env bash

# the resulting chart needs changes in order to be deployed.
# get, update need to be added to the clusterrole permissions for configmaps
# namespace=kube-system needs to be added to the poddisruptionbudget, deployment, and role 

export CLUSTER=$1
export AWS_ACCOUNT_ID=$(cat $CLUSTER.auto.tfvars.json | jq -r .account_id)
export AWS_DEFAULT_REGION=$(cat $CLUSTER.auto.tfvars.json | jq -r .aws_region)
export CLUSTER_AUTOSCALER_VERSION=$(cat $CLUSTER.auto.tfvars.json | jq -r .cluster_autoscaler_version)

# write cluster-autoscaler-chart-values.yaml
cat <<EOF > cluster-autoscaler-chart-values.yaml
nameOverride: "cluster-autoscaler"
awsRegion: ${AWS_DEFAULT_REGION}
cloudProvider: aws
image:
  tag: v${CLUSTER_AUTOSCALER_VERSION}
  pullPolicy: Always
rbac:
  create: true
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${CLUSTER}-cluster-autoscaler"
autoDiscovery:
  clusterName: ${CLUSTER}
  enabled: true
podAnnotations:
  cluster-autoscaler.kubernetes.io/safe-to-evict: "true"
extraArgs:
  skip-nodes-with-local-storage: false
  expander: least-waste
  balance-similar-node-groups: true
  skip-nodes-with-system-pods: false
EOF

helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm template $CLUSTER autoscaler/cluster-autoscaler --namespace kube-system  --values=cluster-autoscaler-chart-values.yaml > cluster-autoscaler-deployment.yaml
