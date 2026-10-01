# Terraform — AWS Data Lake & Warehouse Platform

Infrastructure-as-code for a secure, production-style AWS analytics platform: a multi-zone **S3 data lake**, **AWS Glue** catalog/crawlers/jobs, **Athena** workgroup, **Redshift Serverless** warehouse, **KMS** encryption, least-privilege **IAM**, and **CloudWatch** alarms — deployed through a **GitHub Actions CI/CD** pipeline.

## What gets created
| File | Resources |
|------|-----------|
| `s3.tf` | `raw`, `curated`, `analytics` buckets — versioning, KMS-SSE, public-access block, lifecycle to IA/Glacier |
| `kms.tf` | Customer-managed key with rotation for lake + warehouse |
| `glue.tf` | Glue databases, crawler for the raw zone, PySpark ETL job with job bookmarks |
| `athena.tf` | Workgroup with enforced, encrypted result location and per-query scan limit |
| `redshift.tf` | Redshift Serverless namespace + workgroup |
| `iam.tf` | Glue service role scoped to the lake buckets and KMS key |
| `monitoring.tf` | SNS topic + CloudWatch alarm on Glue job failures |

## Usage
```bash
terraform init
terraform plan  -var="env=dev" -var="alert_email=you@example.com"
terraform apply -var="env=dev" -var="alert_email=you@example.com"
```

## CI/CD
`.github/workflows/terraform.yml` runs `fmt -check`, `validate`, `tflint` and `plan` on every pull request, and `apply` on merge to `main` (using GitHub OIDC → AWS IAM role, no long-lived keys).

## Tech
Terraform · AWS (S3, Glue, Athena, Redshift Serverless, KMS, IAM, CloudWatch, SNS) · GitHub Actions
