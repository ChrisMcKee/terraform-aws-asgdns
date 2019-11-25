module "autoscale_dns" {
  source                              = "../../"
  autoscale_handler_unique_identifier = "${var.cluster_name}-handler"
  autoscale_route53zone_arn           = aws_route53_zone.test.id
  asg_name                            = "${var.cluster_name}-asg"

  namespace = var.namespace
  stage     = var.stage
  name      = var.name
}

resource "aws_launch_configuration" "test" {
  name_prefix = "${var.cluster_name}-handler"

  lifecycle {
    create_before_destroy = true
  }

  image_id                    = var.ami_id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.test.id]
  associate_public_ip_address = var.associate_public_ip_address
}

resource "aws_autoscaling_group" "test" {
  lifecycle {
    create_before_destroy = true
  }

  initial_lifecycle_hook {
    name                    = "${aws_launch_configuration.test.id}-lifecycle-launching"
    default_result          = "CONTINUE"
    heartbeat_timeout       = 60
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
    notification_target_arn = module.autoscale_dns.autoscale_handling_sns_topic_arn
    role_arn                = module.autoscale_dns.agent_lifecycle_iam_role_arn
  }

  initial_lifecycle_hook {
    name                    = "${aws_launch_configuration.test.id}-lifecycle-terminating"
    default_result          = "CONTINUE"
    heartbeat_timeout       = 60
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
    notification_target_arn = module.autoscale_dns.autoscale_handling_sns_topic_arn
    role_arn                = module.autoscale_dns.agent_lifecycle_iam_role_arn
  }

  name = aws_launch_configuration.test.id

  vpc_zone_identifier = module.vpc.private_subnets

  min_size                  = var.min_size
  max_size                  = var.max_size
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = false
  launch_configuration      = aws_launch_configuration.test.name
  termination_policies      = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "cluster"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  tag {
    key                 = "asg:hostname_pattern"
    value               = "asg-test-#clustername.${aws_route53_zone.test.name}@${aws_route53_zone.test.id}"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "test" {
  vpc_id = module.vpc.vpc_id
  name   = "${var.cluster_name}-sg"

  # allow traffic within security group
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

