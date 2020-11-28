variable "amazon_linux_2_patch_baseline_product" { type = "list" }
variable "amazon_linux_2_patch_baseline_classification" { type = "list" }

resource "aws_ssm_patch_baseline" "amazon_linux_2_patch_baseline" {
  name             = "amazon-linux-2-patch-baseline"
  operating_system = "AMAZON_LINUX_2"
  
  approval_rule {
    approve_after_days = 1
    compliance_level   = "UNSPECIFIED"

    patch_filter {
      key    = "PRODUCT"
      values = "${var.amazon_linux_2_patch_baseline_product}"
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important", "Medium", "Low"]
    }

    patch_filter {
      key    = "CLASSIFICATION"
      values = "${var.amazon_linux_2_patch_baseline_classification}"
    }
  }
}

resource "aws_ssm_patch_group" "amazon_linux_2_patch_group" {
  baseline_id = "${aws_ssm_patch_baseline.amazon_linux_2_patch_baseline.id}"
  patch_group = "amazon_linux_2"
}