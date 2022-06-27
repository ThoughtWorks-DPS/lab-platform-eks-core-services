data "aws_eks_cluster" "eks" {
  name = "${var.cluster_name}"
}

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

data "aws_vpc" "cluster_vpc" {
  tags = {
    cluster = var.cluster_name
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.cluster_vpc.id]
  }

  tags = {
    Tier = "private"
  }
}

data "aws_subnet" "private_ids" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_security_groups" "cluster_security_group_id" {
  tags = {
    Name = "${var.cluster_name}-eks_cluster_sg"
  }
}

data "aws_security_groups" "cluster_worker_security_group_id" {
  tags = {
    Name = "${var.cluster_name}-eks_worker_sg"
  }
}

# output "cluster_version" {
#   value = data.aws_eks_cluster.eks.version
# }
