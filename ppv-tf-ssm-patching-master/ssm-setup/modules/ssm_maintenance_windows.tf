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
variable "maintenance_task_max_errors" { }

variable "patching_group1_s3_log_prefix" { }
variable "patching_group2_s3_log_prefix" { }
variable "patching_group3_s3_log_prefix" { }
variable "patching_group4_s3_log_prefix" { }

resource "aws_ssm_maintenance_window" "mw_patching_group1" {
  name     = "${var.mw_patching_group_one_name}"
  schedule = "${var.mw_patching_group_one_schedule}"
  duration = "${var.mw_patching_group_one_duration}"
  cutoff   = "${var.mw_patching_group_one_cutoff}"
}

resource "aws_ssm_maintenance_window_target" "mw_patching_group1_instances" {
  name          = "patching_group_1_window_target"
  description   = "Targets instances for first patch group"
  window_id     = "${aws_ssm_maintenance_window.mw_patching_group1.id}"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:patching_window"
    values = ["10AMUTC"]
  }
}

resource "aws_ssm_maintenance_window" "mw_patching_group2" {
  name     = "${var.mw_patching_group_two_name}"
  schedule = "${var.mw_patching_group_two_schedule}"
  duration = "${var.mw_patching_group_two_duration}"
  cutoff   = "${var.mw_patching_group_two_cutoff}"
}

resource "aws_ssm_maintenance_window_target" "mw_patching_group2_instances" {
  name          = "patching_group_2_window_target"
  description   = "Targets instances for first patch group"
  window_id     = "${aws_ssm_maintenance_window.mw_patching_group2.id}"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:patching_window"
    values = ["1PMUTC"]
  }
}

resource "aws_ssm_maintenance_window" "mw_patching_group3" {
  name     = "${var.mw_patching_group_three_name}"
  schedule = "${var.mw_patching_group_three_schedule}"
  duration = "${var.mw_patching_group_three_duration}"
  cutoff   = "${var.mw_patching_group_three_cutoff}"
}

resource "aws_ssm_maintenance_window_target" "mw_patching_group3_instances" {
  name          = "patching_group_1_window_target"
  description   = "Targets instances for third patch group"
  window_id     = "${aws_ssm_maintenance_window.mw_patching_group3.id}"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:patching_window"
    values = ["430AMUTC"]
  }
}

resource "aws_ssm_maintenance_window" "mw_patching_group4" {
  name     = "${var.mw_patching_group_four_name}"
  schedule = "${var.mw_patching_group_four_schedule}"
  duration = "${var.mw_patching_group_four_duration}"
  cutoff   = "${var.mw_patching_group_four_cutoff}"
}

resource "aws_ssm_maintenance_window_target" "mw_patching_group4_instances" {
  name          = "patching_group_4_window_target"
  description   = "Targets instances for first patch group"
  window_id     = "${aws_ssm_maintenance_window.mw_patching_group4.id}"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:patching_window"
    values = ["230PMUTC"]
  }
}

resource "aws_ssm_maintenance_window_task" "patching_task_group1" {
  window_id        = "${aws_ssm_maintenance_window.mw_patching_group1.id}"
  name             = "maintenance-patching-task-group1"
  description      = "Installs patches servers listed to be patched at 10AM UTC"
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = "${aws_iam_role.ssm_role.arn}"
  max_concurrency  = "${var.maintenance_task_max_concurrency}"
  max_errors       = "${var.maintenance_task_max_errors}"

  targets {
    key    = "WindowTargetIds"
    values = ["${aws_ssm_maintenance_window_target.mw_patching_group1_instances.id}"]
  }

  task_parameters {
    name   = "Operation"
    values = ["Install"]
  }

  logging_info {
    s3_bucket_name   = "${aws_s3_bucket.ssm_patching_bucket.id}"
    s3_region        = "${aws_s3_bucket.ssm_patching_bucket.region}"
    s3_bucket_prefix = "${var.patching_group1_s3_log_prefix}"
  }
}

resource "aws_ssm_maintenance_window_task" "patching_task_group2" {
  window_id        = "${aws_ssm_maintenance_window.mw_patching_group2.id}"
  name             = "maintenance-patching-task-group2"
  description      = "Installs patches servers listed to be patched at 1PM UTC"
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = "${aws_iam_role.ssm_role.arn}"
  max_concurrency  = "${var.maintenance_task_max_concurrency}"
  max_errors       = "${var.maintenance_task_max_errors}"

  targets {
    key    = "WindowTargetIds"
    values = ["${aws_ssm_maintenance_window_target.mw_patching_group2_instances.id}"]
  }

  task_parameters {
    name   = "Operation"
    values = ["Install"]
  }

  logging_info {
    s3_bucket_name   = "${aws_s3_bucket.ssm_patching_bucket.id}"
    s3_region        = "${aws_s3_bucket.ssm_patching_bucket.region}"
    s3_bucket_prefix = "${var.patching_group2_s3_log_prefix}"
  }
}

resource "aws_ssm_maintenance_window_task" "patching_task_group3" {
  window_id        = "${aws_ssm_maintenance_window.mw_patching_group3.id}"
  name             = "maintenance-patching-task-group3"
  description      = "Installs patches servers listed to be patched at 4.30AM UTC"
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = "${aws_iam_role.ssm_role.arn}"
  max_concurrency  = "${var.maintenance_task_max_concurrency}"
  max_errors       = "${var.maintenance_task_max_errors}"

  targets {
    key    = "WindowTargetIds"
    values = ["${aws_ssm_maintenance_window_target.mw_patching_group3_instances.id}"]
  }

  task_parameters {
    name   = "Operation"
    values = ["Install"]
  }

  logging_info {
    s3_bucket_name   = "${aws_s3_bucket.ssm_patching_bucket.id}"
    s3_region        = "${aws_s3_bucket.ssm_patching_bucket.region}"
    s3_bucket_prefix = "${var.patching_group3_s3_log_prefix}"
  }
}


resource "aws_ssm_maintenance_window_task" "patching_task_group4" {
  window_id        = "${aws_ssm_maintenance_window.mw_patching_group4.id}"
  name             = "maintenance-patching-task-group4"
  description      = "Installs patches servers listed to be patched at 2.30PM UTC"
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = "${aws_iam_role.ssm_role.arn}"
  max_concurrency  = "${var.maintenance_task_max_concurrency}"
  max_errors       = "${var.maintenance_task_max_errors}"

  targets {
    key    = "WindowTargetIds"
    values = ["${aws_ssm_maintenance_window_target.mw_patching_group4_instances.id}"]
  }

  task_parameters {
    name   = "Operation"
    values = ["Install"]
  }

  logging_info {
    s3_bucket_name   = "${aws_s3_bucket.ssm_patching_bucket.id}"
    s3_region        = "${aws_s3_bucket.ssm_patching_bucket.region}"
    s3_bucket_prefix = "${var.patching_group3_s3_log_prefix}"
  }
}