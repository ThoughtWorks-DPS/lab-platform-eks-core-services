locals {
  cluster_autoscaler_namespace            = "kube-system"
  cluster_autoscaler_service_account_name = "${var.cluster_name}-cluster-autoscaler"

  # oidc_issuer = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

# cluster-autoscaler
module "assumable_role_cluster_autoscaler" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.1.0"

  create_role                   = true
  role_name                     = "${var.cluster_name}-cluster-autoscaler"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler_role_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cluster_autoscaler_namespace}:${local.cluster_autoscaler_service_account_name}"]
  number_of_role_policy_arns    = 1
}

resource "aws_iam_policy" "cluster_autoscaler_role_policy" {
  name_prefix = "${var.cluster_name}-cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for the ${var.cluster_name} cluster"
  policy      = data.aws_iam_policy_document.cluster_autoscaler_role_policy_document.json
}

data "aws_iam_policy_document" "cluster_autoscaler_role_policy_document" {
  statement {
    sid    = "${var.cluster_name}ClusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "${var.cluster_name}ClusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}
