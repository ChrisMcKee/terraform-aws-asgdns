variable "instance_type" {
  default = "t2.nano"
}

variable "associate_public_ip_address" {
  default = false
}

variable "min_size" {
  default = "1"
}

variable "max_size" {
  default = "3"
}

variable "aws_region" {
  description = "Region for the VPC"
  default     = "eu-west-1"
}

variable "ami_id" {
  description = "AMIs by region"
  default     = "ami-f96c5280"
}

variable "cluster_name" {
  default = "asg-cluster"
}

////

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `eg` or `cp`)"
  default     = "test"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  default     = "testing"
}

variable "name" {
  type        = "string"
  default     = "efs-provider"
  description = "Name (e.g. `efs-provider`)"
  default     = "autodns"
}
