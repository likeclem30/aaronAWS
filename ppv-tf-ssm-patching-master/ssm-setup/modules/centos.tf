#CentOS
variable "centos_patch_baseline_product" { type = "list" }
variable "centos_patch_baseline_classification" { type = "list" }

resource "aws_ssm_patch_baseline" "centos_patch_baseline" {
  name             = "centos-patch-baseline"
  operating_system = "CENTOS"
  
  approval_rule {
    approve_after_days = 1
    compliance_level   = "HIGH"

    patch_filter {
      key    = "PRODUCT"
      values = "${var.centos_patch_baseline_product}"
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important", "Moderate", "Low"]
    }

    patch_filter {
      key    = "CLASSIFICATION"
      values = "${var.centos_patch_baseline_classification}"
    }
  }
}

resource "aws_ssm_patch_group" "centos_patch_group" {
  baseline_id = "${aws_ssm_patch_baseline.centos_patch_baseline.id}"
  patch_group = "centos"
}