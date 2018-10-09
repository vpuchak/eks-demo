variable "region" { default = "us-east-1"}
variable "vpc_cidr_block" {}
variable "env" {}
variable "cluster-name" {
  type = "string"
}

variable "ssh_cidr" { default = "195.160.232.0/22" }