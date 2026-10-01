output "bucket_names" {
  value = { for k, b in aws_s3_bucket.zone : k => b.bucket }
}

output "glue_job_name" {
  value = aws_glue_job.raw_to_curated.name
}

output "athena_workgroup" {
  value = aws_athena_workgroup.analytics.name
}

output "redshift_workgroup_endpoint" {
  value = aws_redshiftserverless_workgroup.dw.endpoint
}

output "kms_key_arn" {
  value = aws_kms_key.lake.arn
}
