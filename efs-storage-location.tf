module "efs_csi_storage" {
  source = "cloudposse/efs/aws"
  version     = "0.32.7"

  name      = "${var.cluster_name}-efs-csi-storage"

  region    = var.aws_region
  vpc_id    = data.aws_vpc.cluster_vpc.id
  subnets   = data.aws_subnets.private.ids

  allowed_cidr_blocks = [for s in data.aws_subnet.private_ids : s.cidr_block]
  associated_security_group_ids = concat(
    data.aws_security_groups.cluster_security_group_id.ids,
    data.aws_security_groups.cluster_worker_security_group_id.ids
  )

  efs_backup_policy_enabled = true
  encrypted                 = true

  tags = {
    "cluster" = var.cluster_name
    "pipeline" = "lab-platform-eks-core-services"
  }
}

output "eks_efs_csi_storage_dns_name" {
  value = module.efs_csi_storage.dns_name
}

output "eks_efs_csi_storage_id" {
  value = module.efs_csi_storage.id
}

output "eks_efs_csi_storage_mount_target_dns_names" {
  value = module.efs_csi_storage.mount_target_dns_names
}

output "eks_efs_csi_storage_mount_target_ids" {
  value = module.efs_csi_storage.mount_target_ids.*
}

output "eks_efs_csi_storage_security_group_id" {
  value = module.efs_csi_storage.security_group_id
}
