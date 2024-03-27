#!/usr/bin/env bats

@test "validate metrics-server version" {
  run bash -c "kubectl get deployment metrics-server -n kube-system -o json | grep $DESIRED_METRICS_SERVER_VERSION"
  [[ "${output}" =~ "metrics-server" ]]
}

@test "validate metrics-server status" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'metrics-server'"
  [[ "${output}" =~ "Running" ]]
}

@test "validate kube-state-metrics status" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'kube-state-metrics'"
  [[ "${output}" =~ "Running" ]]
}

@test "validate cluster-autoscaler status" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'cluster-autoscaler'"
  [[ "${output}" =~ "Running" ]]
}

# @test "validate efs-csi-controller status" {
#   run bash -c "kubectl get po -n kube-system -o wide | grep 'efs-csi-controller'"
#   [[ "${output}" =~ "Running" ]]
# }

# @test "evaluate efs storageclass" {
#   run bash -c "kubectl get storageclasses | grep "${CLUSTER}-efs""
#   [[ "${output}" =~ "Immediate" ]]
# }

# @test "evaluate system roles" {
#   run bash -c "kubectl get clusterroles"
#   [[ "${output}" =~ "admin-clusterrole" ]]
# }

