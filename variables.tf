variable "aws_region" {}
variable "aws_account_id" {
  sensitive = true
}
variable "aws_assume_role" {
  sensitive = true
}

variable "cluster_name" {}
variable "cluster_autoscaler_version" {}
variable "metrics_server_version" {}
variable "kube_state_metrics_chart_version" {}
variable "alert_channel" {}

variable "pixie_deploy_key" {}
