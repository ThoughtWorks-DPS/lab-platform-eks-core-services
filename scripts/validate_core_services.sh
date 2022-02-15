#!/usr/bin/env bash
set -e

export CLUSTER=$1
export AWS_ACCOUNT_ID=$(cat $CLUSTER.auto.tfvars.json | jq -r .account_id)
export AWS_DEFAULT_REGION=$(cat $CLUSTER.auto.tfvars.json | jq -r .aws_region)
export AWS_ASSUME_ROLE=$(cat $CLUSTER.auto.tfvars.json | jq -r .assume_role)
aws sts assume-role --output json --role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/$AWS_ASSUME_ROLE --role-session-name cluster-base-configuration-test > credentials

export AWS_ACCESS_KEY_ID=$(cat credentials | jq -r ".Credentials.AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(cat credentials | jq -r ".Credentials.SecretAccessKey")
export AWS_SESSION_TOKEN=$(cat credentials | jq -r ".Credentials.SessionToken")

export DESIRED_CLUSTER_AUTOSCALER_VERSION=$(cat $CLUSTER.auto.tfvars.json | jq -r .cluster_autoscaler_version)
export DESIRED_METRICS_SERVER_VERSION=$(cat $CLUSTER.auto.tfvars.json | jq -r .metrics_server_version)
export DESIRED_KUBE_STATE_METRICS_VERSION=$(cat $CLUSTER.auto.tfvars.json | jq -r .kube_state_metrics_version)
export EFS_CSI_DRIVER_VERSION=$(cat $CLUSTER.auto.tfvars.json | jq -r .aws_efs_csi_driver_version)
export CSI_PROVISIONER_VERSION=$(cat $CLUSTER.auto.tfvars.json | jq -r .aws_efs_csi_provisionser_version)
export LIVENESS_PROBE_VERSION=$(cat $CLUSTER.auto.tfvars.json | jq -r .aws_eks_liveness_probe_version)
export CSI_NODE_DRIVER_REGISTRAR=$(cat $CLUSTER.auto.tfvars.json | jq -r .aws_efs_csi_node_driver_registrar)

echo "validate core services"
bats test

echo "validate EFS storage class"
# validate dynamic volume provisioning with mulitipod access

export TF_WORKSPACE=$CLUSTER

terraform init
export EFS_FILESYSTEM_ID=$(terraform output eks_efs_csi_storage_id)

cat <<EOF > test/efs-csi/test-efs-storage-class.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: test-efs-csi

---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-csi-test-storage-class
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: $EFS_FILESYSTEM_ID
  directoryPerms: "700"
  basePath: "/dynamic"
EOF

echo "debug:"
cat test/efs-csi/test-efs-storage-class.yaml

kubectl apply -f test/efs-csi/test-efs-storage-class.yaml
sleep 10
kubectl apply -f test/efs-csi/dynamic-multipod-tls/dynamic-claim-test.yaml
sleep 25

bats test/efs-csi/dynamic-multipod-tls

kubectl delete -f test/efs-csi/dynamic-multipod-tls/dynamic-claim-test.yaml
sleep 10
kubectl delete -f test/efs-csi/test-efs-storage-class.yaml
sleep 10
