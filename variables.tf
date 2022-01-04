variable "aws_region" {}
variable "account_id" {
  sensitive = true
}
variable "assume_role" {
  sensitive = true
}

variable "cluster_name" {}
variable "cluster_autoscaler_version" {}
variable "metrics_server_version" {}
variable "kube_state_metrics_version" {}
