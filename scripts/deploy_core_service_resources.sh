#!/usr/bin/env bash
export CLUSTER=$1
export EFS_FILESYSTEM_ID=$(terraform output eks_efs_csi_storage_id)


cat <<EOF > core-service-resources/ebs-storage-class.yaml
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: $CLUSTER-ebs-storage-class
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
# wait until eks-addon supported version includes resizing
# allowVolumeExpansion: true
parameters:
  csi.storage.k8s.io/fstype: xfs
  type: io1
  iopsPerGB: "50"
  encrypted: "true"

EOF

cat <<EOF > core-service-resources/efs-storage-class.yaml
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: $CLUSTER-efs-storage-class
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: $EFS_FILESYSTEM_ID
  directoryPerms: "700"
  basePath: "/${CLUSTER}_dynamic"
EOF

kubectl apply -f core-service-resources --recursive