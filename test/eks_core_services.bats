#!/usr/bin/env bats

@test "validate metrics-server version" {
  run bash -c "kubectl get deployment metrics-server -n kube-system -o json | grep $DESIRED_METRICS_SERVER_VERSION"
  [[ "${output}" =~ "metrics-server" ]]
}

@test "validate metrics-server status" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'metrics-server'"
  [[ "${output}" =~ "Running" ]]
}


@test "validate kube-state-metrics version" {
  run bash -c "kubectl get deployment kube-state-metrics -n kube-system -o json | grep $DESIRED_KUBE_STATE_METRICS_VERSION"
  [[ "${output}" =~ "kube-state-metrics" ]]
}

@test "validate kube-state-metrics status" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'kube-state-metrics'"
  [[ "${output}" =~ "Running" ]]
}


@test "validate cluster-autoscaler version" {
  run bash -c "kubectl get deployment cluster-autoscaler -n kube-system -o json | grep $DESIRED_CLUSTER_AUTOSCALER_VERSION"
  [[ "${output}" =~ "cluster-autoscaler" ]]
}

@test "validate cluster-autoscaler status" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'cluster-autoscaler'"
  [[ "${output}" =~ "Running" ]]
}


@test "validate efs-csi-controller version" {
  run bash -c "kubectl get deployment efs-csi-controller -n kube-system -o json | grep $EFS_CSI_DRIVER_VERSION"
  [[ "${output}" =~ "aws-efs-csi-driver" ]]
}

@test "validate efs-csi-controller provisioner version" {
  run bash -c "kubectl get deployment efs-csi-controller -n kube-system -o json | grep $CSI_PROVISIONER_VERSION"
  [[ "${output}" =~ "csi-provisioner" ]]
}

@test "validate efs-csi-controller status" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'efs-csi-controller'"
  [[ "${output}" =~ "Running" ]]
}

@test "validate efs-csi-controller liveness probe version" {
  run bash -c "kubectl get deployment efs-csi-controller -n kube-system -o json | grep $LIVENESS_PROBE_VERSION"
  [[ "${output}" =~ "livenessprobe" ]]
}

@test "validate efs-csi-node version" {
  run bash -c "kubectl get daemonset efs-csi-node -n kube-system -o json | grep $EFS_CSI_DRIVER_VERSION"
  [[ "${output}" =~ "aws-efs-csi-driver" ]]
}

@test "validate efs-csi-node registrar version" {
  run bash -c "kubectl get daemonset efs-csi-node -n kube-system -o json | grep $CSI_NODE_DRIVER_REGISTRAR"
  [[ "${output}" =~ "csi-node-driver-registrar" ]]
}

@test "validate efs-csi-node liveness probe version" {
  run bash -c "kubectl get daemonset efs-csi-node -n kube-system -o json | grep $LIVENESS_PROBE_VERSION"
  [[ "${output}" =~ "livenessprobe" ]]
}

@test "evaluate ebs storageclass" {
  run bash -c "kubectl get storageclasses | grep "${CLUSTER}-ebs""
  [[ "${output}" =~ "WaitForFirstConsumer" ]]
}

@test "evaluate efs storageclass" {
  run bash -c "kubectl get storageclasses | grep "${CLUSTER}-efs""
  [[ "${output}" =~ "Immediate" ]]
}

@test "evaluate standard namespaces" {
  run bash -c "kubectl get ns"
  [[ "${output}" =~ "lab-system" ]]
}

@test "evaluate system roles" {
  run bash -c "kubectl get clusterroles"
  [[ "${output}" =~ "admin-clusterrole" ]]
}

@test "validate datadog-agent status" {
  run bash -c "kubectl get po -n datadog -o wide | grep 'datadog-agent'"
  [[ "${output}" =~ "Running" ]]
}

@test "validate datadog-cluster-agent status" {
  run bash -c "kubectl get po -n datadog -o wide | grep 'datadog-agent-cluster-agent'"
  [[ "${output}" =~ "Running" ]]
}
