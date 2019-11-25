# Terraform Module: AutoScaling with DNS update (AWS)

ASG with lifecycle and lambda to update a R53 record with the ips of the instances.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| asg\_name | The name of the ASG | string | n/a | yes |
| attributes | Additional attributes \(e.g. `1`\) | list(string) | `[]` | no |
| autoscale\_handler\_unique\_identifier | asg\_dns\_handler | string | n/a | yes |
| autoscale\_route53zone\_arn | The ARN of route53 zone associated with autoscaling group | string | n/a | yes |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `"-"` | no |
| name | Name \(e.g. `efs-provider`\) | string | `"efs-provider"` | no |
| namespace | Namespace \(e.g. `eg` or `cp`\) | string | n/a | yes |
| stage | Stage \(e.g. `prod`, `dev`, `staging`\) | string | n/a | yes |
| tags | Additional tags \(e.g. `\{ BusinessUnit = "XYZ" \}` | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| agent\_lifecycle\_iam\_role\_arn | IAM Role ARN for lifecycle\_hooks |
| autoscale\_handling\_sns\_topic\_arn | SNS topic ARN for autocaling group |
| autoscale\_iam\_role\_arn | IAM role ARN for autocscaling group |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
