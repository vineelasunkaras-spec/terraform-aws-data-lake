resource "aws_sns_topic" "alerts" {
  name              = "${local.prefix}-data-alerts"
  kms_master_key_id = aws_kms_key.lake.id
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_event_rule" "glue_failed" {
  name = "${local.prefix}-glue-job-failed"

  event_pattern = jsonencode({
    source      = ["aws.glue"]
    detail-type = ["Glue Job State Change"]
    detail      = { state = ["FAILED", "TIMEOUT"], jobName = [aws_glue_job.raw_to_curated.name] }
  })
}

resource "aws_cloudwatch_event_target" "glue_failed_sns" {
  rule = aws_cloudwatch_event_rule.glue_failed.name
  arn  = aws_sns_topic.alerts.arn
}
