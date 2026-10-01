resource "aws_redshiftserverless_namespace" "dw" {
  namespace_name        = "${local.prefix}-dw"
  db_name               = "analytics"
  kms_key_id            = aws_kms_key.lake.arn
  manage_admin_password = true
  log_exports           = ["userlog", "connectionlog", "useractivitylog"]
}

resource "aws_redshiftserverless_workgroup" "dw" {
  namespace_name      = aws_redshiftserverless_namespace.dw.namespace_name
  workgroup_name      = "${local.prefix}-dw"
  base_capacity       = var.redshift_base_rpu
  publicly_accessible = false
}
