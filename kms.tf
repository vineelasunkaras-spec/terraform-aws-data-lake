resource "aws_kms_key" "lake" {
  description             = "${local.prefix} data lake & warehouse key"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "lake" {
  name          = "alias/${local.prefix}-lake"
  target_key_id = aws_kms_key.lake.key_id
}
