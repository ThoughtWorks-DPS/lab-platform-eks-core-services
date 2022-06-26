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

variable "datadog_api_key" {}
variable "datadog_app_key" {}
variable "datadog_cluster_agent_version" {}
variable "datadog_agent_version" {}
