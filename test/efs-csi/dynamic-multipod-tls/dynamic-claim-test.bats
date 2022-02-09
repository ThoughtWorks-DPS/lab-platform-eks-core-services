#!/usr/bin/env bats

@test "validate bound dynamic efs pvc" {
  run bash -c "kubectl get pvc -n test-efs-csi"
  [[ "${output}" =~ "Bound" ]]
}

@test "validate dynamic efs pvc RWX access - pod 1 reading pod 2 writes" {
  run bash -c "kubectl exec -ti -n test-efs-csi claim-test-pod-1 -- head -n 5 /data/out2"
  [[ "${output}" =~ "pod2" ]]
}

@test "validate dynamic efs pvc RWX access - pod 2 reading pod 1 writes" {
  run bash -c "kubectl exec -ti -n test-efs-csi claim-test-pod-2 -- head -n 5 /data/out1"
  [[ "${output}" =~ "UTC" ]]
}
