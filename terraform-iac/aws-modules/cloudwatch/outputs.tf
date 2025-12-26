output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}

output "dashboard_name" {
  value = var.enable_dashboard ? aws_cloudwatch_dashboard.this[0].dashboard_name : null
}
