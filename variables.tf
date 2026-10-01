variable "project" {
  type    = string
  default = "data-platform"
}

variable "env" {
  type = string
  validation {
    condition     = contains(["dev", "qa", "prod"], var.env)
    error_message = "env must be dev, qa or prod."
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "alert_email" {
  type = string
}

variable "redshift_base_rpu" {
  type    = number
  default = 8
}

variable "athena_bytes_scanned_cutoff" {
  type    = number
  default = 10737418240 # 10 GB per query
}

locals {
  prefix = "${var.project}-${var.env}"
  zones  = ["raw", "curated", "analytics"]
}
