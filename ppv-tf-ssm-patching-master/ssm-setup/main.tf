##Misc
variable "ssm_patching_bucket_name" { }

#Amazon Linux
variable "amazon_linux_patch_baseline_product" { type = "list" }
variable "amazon_linux_patch_baseline_classification" { type = "list" }

#Amazon Linux 2
variable "amazon_linux_2_patch_baseline_product" { type = "list" }
variable "amazon_linux_2_patch_baseline_classification" { type = "list" }

#Ubuntu
variable "ubuntu_patch_baseline_product" { type = "list" }
variable "ubuntu_patch_baseline_section" { type = "list" }
variable "ubuntu_patch_baseline_priority" { type = "list" }

#CentOS
variable "centos_patch_baseline_product" { type = "list" }
variable "centos_patch_baseline_classification" { type = "list" }

#RHEL
variable "rhel_patch_baseline_product" { type = "list" }
variable "rhel_patch_baseline_classification" { type = "list" }

#Windows 2008
variable "windows2008_patch_baseline_product" { type = "list" }
variable "windows2008_patch_baseline_classification" { type = "list" }
variable "windows2008_patch_baseline_approve_after_days" { }

#Windows 2012
variable "windows2012_patch_baseline_product" { type = "list" }
variable "windows2012_patch_baseline_classification" { type = "list" }
variable "windows2012_patch_baseline_approve_after_days" { }

#Windows 2016
variable "windows2016_patch_baseline_product" { type = "list" }
variable "windows2016_patch_baseline_classification" { type = "list" }
variable "windows2016_patch_baseline_approve_after_days" { }

#Maintenance Windows
variable "mw_patching_group_one_name"     { }
variable "mw_patching_group_one_schedule" { }
variable "mw_patching_group_one_duration" { }
variable "mw_patching_group_one_cutoff"   { }

variable "mw_patching_group_two_name"     { }
variable "mw_patching_group_two_schedule" { }
variable "mw_patching_group_two_duration" { }
variable "mw_patching_group_two_cutoff"   { }

variable "mw_patching_group_three_name"     { }
variable "mw_patching_group_three_schedule" { }
variable "mw_patching_group_three_duration" { }
variable "mw_patching_group_three_cutoff"   { }

variable "mw_patching_group_four_name"     { }
variable "mw_patching_group_four_schedule" { }
variable "mw_patching_group_four_duration" { }
variable "mw_patching_group_four_cutoff"   { }

variable "maintenance_task_max_concurrency" { }
variable "maintenance_task_max_errors"      { }
variable "patching_group1_s3_log_prefix"    { }
variable "patching_group2_s3_log_prefix"    { }
variable "patching_group3_s3_log_prefix"    { }
variable "patching_group4_s3_log_prefix"    { }

provider "aws" {
  region     = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "ndm-ppv-tfstate"
    key = "ppv-tf-ssm-patching/ppv-ssm-patching.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

module "main" {
  source = "./modules"

  ssm_patching_bucket_name = "${var.ssm_patching_bucket_name}"

  amazon_linux_patch_baseline_product        = "${var.amazon_linux_patch_baseline_product}"
  amazon_linux_patch_baseline_classification = "${var.amazon_linux_patch_baseline_classification}"

  amazon_linux_2_patch_baseline_product        = "${var.amazon_linux_2_patch_baseline_product}"
  amazon_linux_2_patch_baseline_classification = "${var.amazon_linux_2_patch_baseline_classification}"

  ubuntu_patch_baseline_product        = "${var.ubuntu_patch_baseline_product}"
  ubuntu_patch_baseline_section        = "${var.ubuntu_patch_baseline_section}"
  ubuntu_patch_baseline_priority       = "${var.ubuntu_patch_baseline_priority}"

  centos_patch_baseline_product        = "${var.centos_patch_baseline_product}"
  centos_patch_baseline_classification = "${var.centos_patch_baseline_classification}"

  rhel_patch_baseline_product        = "${var.rhel_patch_baseline_product}"
  rhel_patch_baseline_classification = "${var.rhel_patch_baseline_classification}"

  windows2008_patch_baseline_product        = "${var.windows2008_patch_baseline_product}"
  windows2008_patch_baseline_classification = "${var.windows2008_patch_baseline_classification}"
  windows2008_patch_baseline_approve_after_days = "${var.windows2008_patch_baseline_approve_after_days}"

  windows2012_patch_baseline_product        = "${var.windows2012_patch_baseline_product}"
  windows2012_patch_baseline_classification = "${var.windows2012_patch_baseline_classification}"
  windows2012_patch_baseline_approve_after_days = "${var.windows2012_patch_baseline_approve_after_days}"

  windows2016_patch_baseline_product        = "${var.windows2016_patch_baseline_product}"
  windows2016_patch_baseline_classification = "${var.windows2016_patch_baseline_classification}"
  windows2016_patch_baseline_approve_after_days = "${var.windows2016_patch_baseline_approve_after_days}"

  mw_patching_group_one_name     = "${var.mw_patching_group_one_name}"
  mw_patching_group_one_schedule = "${var.mw_patching_group_one_schedule}"
  mw_patching_group_one_duration = "${var.mw_patching_group_one_duration}"
  mw_patching_group_one_cutoff   = "${var.mw_patching_group_one_cutoff}"

  mw_patching_group_two_name     = "${var.mw_patching_group_two_name}"
  mw_patching_group_two_schedule = "${var.mw_patching_group_two_schedule}"
  mw_patching_group_two_duration = "${var.mw_patching_group_two_duration}"
  mw_patching_group_two_cutoff   = "${var.mw_patching_group_two_cutoff}"

  mw_patching_group_three_name     = "${var.mw_patching_group_three_name}"
  mw_patching_group_three_schedule = "${var.mw_patching_group_three_schedule}"
  mw_patching_group_three_duration = "${var.mw_patching_group_three_duration}"
  mw_patching_group_three_cutoff   = "${var.mw_patching_group_three_cutoff}"
 
  mw_patching_group_four_name     = "${var.mw_patching_group_four_name}"
  mw_patching_group_four_schedule = "${var.mw_patching_group_four_schedule}"
  mw_patching_group_four_duration = "${var.mw_patching_group_four_duration}"
  mw_patching_group_four_cutoff   = "${var.mw_patching_group_four_cutoff}"

  maintenance_task_max_concurrency = "${var.maintenance_task_max_concurrency}"
  maintenance_task_max_errors      = "${var.maintenance_task_max_errors}"
  patching_group1_s3_log_prefix    = "${var.patching_group1_s3_log_prefix}"
  patching_group2_s3_log_prefix    = "${var.patching_group2_s3_log_prefix}"
  patching_group3_s3_log_prefix    = "${var.patching_group3_s3_log_prefix}"
  patching_group4_s3_log_prefix    = "${var.patching_group4_s3_log_prefix}"

}