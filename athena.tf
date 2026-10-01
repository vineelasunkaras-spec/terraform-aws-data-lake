resource "aws_athena_workgroup" "analytics" {
  name = "${local.prefix}-analytics"
  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    bytes_scanned_cutoff_per_query     = var.athena_bytes_scanned_cutoff
    result_configuration {
      output_location = "s3://${aws_s3_bucket.zone["analytics"].bucket}/athena-results/"
      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.lake.arn
      }
    }
  }
}
