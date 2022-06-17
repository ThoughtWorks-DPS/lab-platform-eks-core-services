terraform {
  required_version = "~> 1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "twdps"
    workspaces {
      prefix = "lab-platform-eks-core-services-"
    }
  }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/${var.aws_assume_role}"
    session_name = "lab-platform-eks-core-services"
  }

  default_tags {
    tags = {
      env      = var.cluster_name
      cluster  = var.cluster_name
      pipeline = "lab-platform-eks-core-services"
    }
  }
}
