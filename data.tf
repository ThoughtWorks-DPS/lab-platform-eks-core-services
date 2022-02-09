data "aws_eks_cluster" "cluster" {
  name = "${var.cluster_name}"
}

data "aws_vpc" "cluster_vpc" {
  tags = {
    cluster = var.cluster_name
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.cluster_vpc.id

  tags = {
    Tier = "private"
  }
}

data "aws_subnet" "private_ids" {
  for_each = data.aws_subnet_ids.private.ids
  id       = each.value
}

data "aws_security_groups" "cluster_worker_security_group_id" {
  tags = {
    Name = "${var.cluster_name}-eks_worker_sg"
  }
}

data "aws_security_groups" "cluster_security_group_id" {
  tags = {
    Name = "${var.cluster_name}-eks_cluster_sg"
  }
}
