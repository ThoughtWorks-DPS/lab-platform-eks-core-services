#!/usr/bin/env bash
export CLUSTER=$1
export AWS_ACCOUNT_ID=$(cat $CLUSTER.auto.tfvars.json | jq -r .account_id)
export AWS_DEFAULT_REGION=$(cat $CLUSTER.auto.tfvars.json | jq -r .aws_region)

# write cluster-autoscaler-chart-values.yaml
cat <<EOF > cluster-autoscaler-chart-values.yaml
nameOverride: "cluster-autoscaler"

awsRegion: ${AWS_DEFAULT_REGION}

rbac:
  create: true
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${CLUSTER}-cluster-autoscaler"

autoDiscovery:
  clusterName: ${CLUSTER}
  enabled: true

podAnnotations:
  cluster-autoscaler.kubernetes.io/safe-to-evict: "false"

extraArgs:
  skip-nodes-with-local-storage: false
  expander: least-waste
  balance-similar-node-groups: true
  skip-nodes-with-system-pods: false

EOF

helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm template $CLUSTER autoscaler/cluster-autoscaler --namespace kube-system  --values=cluster-autoscaler-chart-values.yaml > cluster-autoscaler-deployment.yaml
kubectl apply -n kube-system -f cluster-autoscaler-deployment.yaml
