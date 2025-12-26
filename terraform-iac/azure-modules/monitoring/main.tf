resource "azurerm_log_analytics_workspace" "this" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.workspace_sku
  retention_in_days   = var.retention_days

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "diagnostics" {
  count                      = length(var.diagnostic_targets)
  name                       = "${var.workspace_name}-diag-${count.index}"
  target_resource_id         = var.diagnostic_targets[count.index]
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  dynamic "log" {
    for_each = var.logs
    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = var.metrics
    content {
      category = metric.value
      enabled  = true

      retention_policy {
        enabled = false
      }
    }
  }
}
