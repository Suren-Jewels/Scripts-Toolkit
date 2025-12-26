resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "CPU usage is above threshold"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = merge(
    {
      Name = "${var.name}-cpu-high"
    },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/${var.name}/logs"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Name = "${var.name}-log-group"
    },
    var.tags
  )
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.name}-dashboard"
  dashboard_body = var.dashboard_body
}
