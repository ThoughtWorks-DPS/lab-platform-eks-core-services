variable "aws_region" {}
variable "account_id" {
  sensitive = true
}
variable "assume_role" {
  sensitive = true
}

variable "cluster_name" {}
variable "cluster_version" {}
