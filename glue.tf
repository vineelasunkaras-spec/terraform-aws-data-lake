resource "aws_glue_catalog_database" "zone" {
  for_each = toset(local.zones)
  name     = replace("${local.prefix}_${each.key}", "-", "_")
}

resource "aws_glue_crawler" "raw" {
  name          = "${local.prefix}-raw-crawler"
  role          = aws_iam_role.glue.arn
  database_name = aws_glue_catalog_database.zone["raw"].name
  schedule      = "cron(0 3 * * ? *)"
  s3_target { path = "s3://${aws_s3_bucket.zone["raw"].bucket}/" }
  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "LOG"
  }
}

resource "aws_s3_object" "etl_script" {
  bucket = aws_s3_bucket.artifacts.id
  key    = "glue/raw_to_curated.py"
  source = "${path.module}/scripts/raw_to_curated.py"
  etag   = filemd5("${path.module}/scripts/raw_to_curated.py")
}

resource "aws_glue_job" "raw_to_curated" {
  name              = "${local.prefix}-raw-to-curated"
  role_arn          = aws_iam_role.glue.arn
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 5
  timeout           = 60
  command {
    script_location = "s3://${aws_s3_bucket.artifacts.bucket}/${aws_s3_object.etl_script.key}"
    python_version  = "3"
  }
  default_arguments = {
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--SOURCE_DB"                        = aws_glue_catalog_database.zone["raw"].name
    "--TARGET_PATH"                      = "s3://${aws_s3_bucket.zone["curated"].bucket}/"
  }
}
