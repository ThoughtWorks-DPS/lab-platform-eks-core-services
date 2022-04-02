module "assumable_role_cluster_autoscaler" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~>4.7"

  create_role                   = true
  role_name                     = "${var.cluster_name}-cluster-autoscaler"
  provider_url                  = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler_role_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:cluster-autoscaler"]
  number_of_role_policy_arns    = 1
}

resource "aws_iam_policy" "cluster_autoscaler_role_policy" {
  name_prefix = "${var.cluster_name}-cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for the ${var.cluster_name} cluster"
  policy      = data.aws_iam_policy_document.cluster_autoscaler_role_policy_document.json
}

data "aws_iam_policy_document" "cluster_autoscaler_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}
