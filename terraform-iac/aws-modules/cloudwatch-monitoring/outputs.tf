output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.this.dashboard_name
}
