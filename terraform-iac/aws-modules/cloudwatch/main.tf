resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = var.retention_days

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alarms" {
  count               = length(var.metric_alarms)
  alarm_name          = var.metric_alarms[count.index].name
  comparison_operator = var.metric_alarms[count.index].comparison_operator
  evaluation_periods  = var.metric_alarms[count.index].evaluation_periods
  metric_name         = var.metric_alarms[count.index].metric_name
  namespace           = var.metric_alarms[count.index].namespace
  period              = var.metric_alarms[count.index].period
  statistic           = var.metric_alarms[count.index].statistic
  threshold           = var.metric_alarms[count.index].threshold
  alarm_description   = var.metric_alarms[count.index].description
  alarm_actions       = var.metric_alarms[count.index].alarm_actions
  ok_actions          = var.metric_alarms[count.index].ok_actions
  dimensions          = var.metric_alarms[count.index].dimensions

  tags = var.tags
}

resource "aws_cloudwatch_dashboard" "this" {
  count          = var.enable_dashboard ? 1 : 0
  dashboard_name = var.dashboard_name
  dashboard_body = var.dashboard_body
}
