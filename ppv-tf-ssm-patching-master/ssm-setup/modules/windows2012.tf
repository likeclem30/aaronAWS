#Windows 2012
variable "windows2012_patch_baseline_product" { type = "list" }
variable "windows2012_patch_baseline_classification" { type = "list" }
variable "windows2012_patch_baseline_approve_after_days" { }

resource "aws_ssm_patch_baseline" "windows2012_patch_baseline" {
  name             = "windows2012-patch-baseline"
  operating_system = "WINDOWS"
  
  approval_rule {
    approve_after_days = "${var.windows2012_patch_baseline_approve_after_days}"
    compliance_level   = "HIGH"

    patch_filter {
      key    = "PRODUCT"
      values = "${var.windows2012_patch_baseline_product}"
    }

    patch_filter {
      key    = "CLASSIFICATION"
      values = "${var.windows2012_patch_baseline_classification}"
    }
  }
}

resource "aws_ssm_patch_group" "windows2012_patch_group" {
  baseline_id = "${aws_ssm_patch_baseline.windows2012_patch_baseline.id}"
  patch_group = "windows2012"
}