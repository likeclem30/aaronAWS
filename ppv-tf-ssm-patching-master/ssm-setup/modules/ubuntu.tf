variable "ubuntu_patch_baseline_product" { type = "list" }
variable "ubuntu_patch_baseline_section" { type = "list" }
variable "ubuntu_patch_baseline_priority" { type = "list" }

resource "aws_ssm_patch_baseline" "ubuntu_patch_baseline" {
  name             = "ubuntu-patch-baseline"
  operating_system = "UBUNTU"
  
  approval_rule {
    approve_after_days = 7
    compliance_level   = "CRITICAL"

    patch_filter {
      key    = "PRODUCT"
      values = "${var.ubuntu_patch_baseline_product}"
    }

    patch_filter {
      key    = "SECTION" 
      values = "${var.ubuntu_patch_baseline_section}"
    }

    patch_filter {
      key    = "PRIORITY"
      values = "${var.ubuntu_patch_baseline_priority}"
    }
  }

  approval_rule {
    approve_after_days = 7
    compliance_level   = "HIGH"

    patch_filter {
      key    = "PRODUCT"
      values = "${var.ubuntu_patch_baseline_product}"
    }

    patch_filter {
      key    = "SECTION" 
      values = "${var.ubuntu_patch_baseline_section}"
    }

    patch_filter {
      key    = "PRIORITY"
      values = "${var.ubuntu_patch_baseline_priority}"
    }
  }

    approval_rule {
    approve_after_days = 7
    compliance_level   = "MEDIUM"

    patch_filter {
      key    = "PRODUCT"
      values = "${var.ubuntu_patch_baseline_product}"
    }

    patch_filter {
      key    = "SECTION" 
      values = "${var.ubuntu_patch_baseline_section}"
    }

    patch_filter {
      key    = "PRIORITY"
      values = "${var.ubuntu_patch_baseline_priority}"
    }
  }

    approval_rule {
    approve_after_days = 7
    compliance_level   = "LOW"

    patch_filter {
      key    = "PRODUCT"
      values = "${var.ubuntu_patch_baseline_product}"
    }

    patch_filter {
      key    = "SECTION" 
      values = "${var.ubuntu_patch_baseline_section}"
    }

    patch_filter {
      key    = "PRIORITY"
      values = "${var.ubuntu_patch_baseline_priority}"
    }
  }

}

resource "aws_ssm_patch_group" "ubuntu_patch_group" {
  baseline_id = "${aws_ssm_patch_baseline.ubuntu_patch_baseline.id}"
  patch_group = "ubuntu"
}