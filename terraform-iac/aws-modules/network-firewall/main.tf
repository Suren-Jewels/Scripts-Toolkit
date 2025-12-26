resource "aws_networkfirewall_firewall_policy" "this" {
  name = "${var.name}-policy"

  firewall_policy {
    stateless_default_actions          = var.stateless_default_actions
    stateless_fragment_default_actions = var.stateless_fragment_default_actions

    dynamic "stateless_rule_group_reference" {
      for_each = var.stateless_rule_group_arns
      content {
        resource_arn = stateless_rule_group_reference.value
        priority     = 100
      }
    }

    dynamic "stateful_rule_group_reference" {
      for_each = var.stateful_rule_group_arns
      content {
        resource_arn = stateful_rule_group_reference.value
      }
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_firewall" "this" {
  name                = var.name
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this.arn
  vpc_id              = var.vpc_id

  subnet_mapping {
    subnet_id = var.subnet_ids[0]
  }

  dynamic "subnet_mapping" {
    for_each = slice(var.subnet_ids, 1, length(var.subnet_ids))
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_logging_configuration" "this" {
  firewall_arn = aws_networkfirewall_firewall.this.arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        bucketName = var.s3_bucket_name
      }
      log_destination_type = "S3"
      log_type             = "FLOW"
    }

    log_destination_config {
      log_destination = {
        bucketName = var.s3_bucket_name
      }
      log_destination_type = "S3"
      log_type             = "ALERT"
    }
  }
}
