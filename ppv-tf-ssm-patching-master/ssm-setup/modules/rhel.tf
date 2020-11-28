#RHEL
variable "rhel_patch_baseline_product" { type = "list" }
variable "rhel_patch_baseline_classification" { type = "list" }

resource "aws_ssm_patch_baseline" "rhel_patch_baseline" {
  name             = "rhel-patch-baseline"
  operating_system = "REDHAT_ENTERPRISE_LINUX"
  
  approval_rule {
    approve_after_days = 7
    compliance_level   = "HIGH"

    patch_filter {
      key    = "PRODUCT"
      values = "${var.rhel_patch_baseline_product}"
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important", "Moderate", "Low"]
    }

    patch_filter {
      key    = "CLASSIFICATION"
      values = "${var.rhel_patch_baseline_classification}"
    }
  }
}

resource "aws_ssm_patch_group" "rhel_patch_group" {
  baseline_id = "${aws_ssm_patch_baseline.rhel_patch_baseline.id}"
  patch_group = "rhel"
}