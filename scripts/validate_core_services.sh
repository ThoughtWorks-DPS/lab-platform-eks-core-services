#!/usr/bin/env bash
set -e

export CLUSTER=$1
export AWS_ACCOUNT_ID=$(cat $CLUSTER.auto.tfvars.json | jq -r .aws_account_id)
export AWS_DEFAULT_REGION=$(cat $CLUSTER.auto.tfvars.json | jq -r .aws_region)
export AWS_ASSUME_ROLE=$(cat $CLUSTER.auto.tfvars.json | jq -r .aws_assume_role)
# aws sts assume-role --output json --role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/$AWS_ASSUME_ROLE --role-session-name lab-platform-eks-core-services > credentials

# export AWS_ACCESS_KEY_ID=$(cat credentials | jq -r ".Credentials.AccessKeyId")
# export AWS_SECRET_ACCESS_KEY=$(cat credentials | jq -r ".Credentials.SecretAccessKey")
# export AWS_SESSION_TOKEN=$(cat credentials | jq -r ".Credentials.SessionToken")

export DESIRED_METRICS_SERVER_VERSION=$(cat $CLUSTER.auto.tfvars.json | jq -r .metrics_server_version)

echo "debug:"
echo "AWS_ACCOUNT_ID: $AWS_ACCOUNT_ID"
echo "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
echo "AWS_ASSUME_ROLE: $AWS_ASSUME_ROLE"

echo "validate core services"
bats test

# echo "validate EFS storage class"
# validate dynamic volume provisioning with mulitipod access

# export TF_WORKSPACE=$CLUSTER

# terraform init
# export EFS_FILESYSTEM_ID=$(terraform output eks_efs_csi_storage_id)

# cat <<EOF > test/efs-csi/test-efs-storage-class.yaml
# ---
# kind: StorageClass
# apiVersion: storage.k8s.io/v1
# metadata:
#   name: efs-csi-test-storage-class
# provisioner: efs.csi.aws.com
# parameters:
#   provisioningMode: efs-ap
#   fileSystemId: $EFS_FILESYSTEM_ID
#   directoryPerms: "700"
#   basePath: "/${CLUSTER}_test"
# EOF

# # echo "debug:"
# # cat test/efs-csi/test-efs-storage-class.yaml

# kubectl apply -f test/efs-csi/test-efs-storage-class.yaml
# sleep 10
# kubectl apply -f test/efs-csi/dynamic-multipod-tls/dynamic-claim-test.yaml
# sleep 25

# bats test/efs-csi/dynamic-multipod-tls

# kubectl delete -f test/efs-csi/dynamic-multipod-tls/dynamic-claim-test.yaml
# sleep 30
# kubectl delete -f test/efs-csi/test-efs-storage-class.yaml
