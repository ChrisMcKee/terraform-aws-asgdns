variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = string
  default     = "efs-provider"
  description = "Name (e.g. `efs-provider`)"
}

variable "delimiter" {
  type        = string
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
  default     = "-"
}

variable "attributes" {
  type        = list(string)
  description = "Additional attributes (e.g. `1`)"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (e.g. `{ BusinessUnit = \"XYZ\" }`"
  default     = {}
}

//

variable "autoscale_handler_unique_identifier" {
  description = "asg_dns_handler"
}

variable "asg_name" {
  description = "The name of the ASG"
}

variable "autoscale_route53zone_arn" {
  description = "The ARN of route53 zone associated with autoscaling group"
}

