resource "aws_route53_zone" "this" {
  name = var.domain_name

  tags = var.tags
}

resource "aws_route53_record" "primary" {
  count   = var.enable_failover ? 1 : 0
  zone_id = aws_route53_zone.this.zone_id
  name    = var.record_name
  type    = var.record_type
  ttl     = var.ttl

  set_identifier = "primary"
  failover_routing_policy {
    type = "PRIMARY"
  }

  records = [var.primary_value]
}

resource "aws_route53_record" "secondary" {
  count   = var.enable_failover ? 1 : 0
  zone_id = aws_route53_zone.this.zone_id
  name    = var.record_name
  type    = var.record_type
  ttl     = var.ttl

  set_identifier = "secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }

  records = [var.secondary_value]
}

resource "aws_route53_record" "latency" {
  count   = var.enable_latency ? length(var.latency_records) : 0
  zone_id = aws_route53_zone.this.zone_id
  name    = var.record_name
  type    = var.record_type
  ttl     = var.ttl

  set_identifier = var.latency_records[count.index].identifier
  latency_routing_policy {
    region = var.latency_records[count.index].region
  }

  records = [var.latency_records[count.index].value]
}

resource "aws_route53_record" "weighted" {
  count   = var.enable_weighted ? length(var.weighted_records) : 0
  zone_id = aws_route53_zone.this.zone_id
  name    = var.record_name
  type    = var.record_type
  ttl     = var.ttl

  set_identifier = var.weighted_records[count.index].identifier
  weighted_routing_policy {
    weight = var.weighted_records[count.index].weight
  }

  records = [var.weighted_records[count.index].value]
}
