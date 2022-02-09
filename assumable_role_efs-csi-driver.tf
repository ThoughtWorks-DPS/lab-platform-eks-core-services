module "efs_csi_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v4.7.0"

  create_role                   = true
  role_name                     = "${var.cluster_name}-efs-csi-controller-sa"
  provider_url                  = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  role_policy_arns              = [aws_iam_policy.efs_csi_role_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
  number_of_role_policy_arns    = 1
}

resource "aws_iam_policy" "efs_csi_role_policy" {
  name        = "${var.cluster_name}_AmazonEKS_EFS_CSI_Driver_Policy"
  description = "EKS EFS CSI policy for efs storage class"
  policy      = data.aws_iam_policy_document.efs_csi_driver_policy_document.json
}

data "aws_iam_policy_document" "efs_csi_driver_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:CreateAccessPoint" 
    ]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:DeleteAccessPoint" 
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }

  }
}
