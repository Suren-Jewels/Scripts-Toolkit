resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_elasticache_parameter_group" "this" {
  name   = "${var.name}-param-group"
  family = var.family

  tags = var.tags
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = var.name
  replication_group_description = var.description
  engine                        = "redis"
  engine_version                = var.engine_version
  node_type                     = var.node_type
  number_cache_clusters         = var.node_count
  parameter_group_name          = aws_elasticache_parameter_group.this.name
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  port                          = var.port
  automatic_failover_enabled    = var.automatic_failover
  multi_az_enabled              = var.multi_az
  at_rest_encryption_enabled    = var.at_rest_encryption
  transit_encryption_enabled    = var.transit_encryption
  security_group_ids            = var.security_group_ids

  tags = var.tags
}
