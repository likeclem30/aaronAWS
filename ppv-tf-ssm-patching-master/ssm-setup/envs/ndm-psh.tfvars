## Generic
ssm_patching_bucket_name = "psh-ssm-patching-logs"

## Amazon Linux
amazon_linux_maintenance_window_duration   = 3
amazon_linux_maintenance_window_cutoff     = 1
amazon_linux_maintenance_window_schedule   = "cron(0 0 5 ? 1/1 MON#4 *)"
amazon_linux_patching_task_max_concurrency = "1"
amazon_linux_patching_task_max_errors      = "1"
amazon_linux_s3_log_prefix                 = "InstallPatchLogs_AWSLinux"
amazon_linux_patch_baseline_product        = ["*"]
amazon_linux_patch_baseline_classification = ["Security", "Bugfix"]

## Amazon Linux 2
amazon_linux_2_maintenance_window_duration   = 3
amazon_linux_2_maintenance_window_cutoff     = 1
amazon_linux_2_maintenance_window_schedule   = "cron(0 0 5 ? 1/1 MON#4 *)"
amazon_linux_2_patching_task_max_concurrency = "25%"
amazon_linux_2_patching_task_max_errors      = "1"
amazon_linux_2_s3_log_prefix                 = "InstallPatchLogs_AWSLinux2"
amazon_linux_2_patch_baseline_product        = ["*"]
amazon_linux_2_patch_baseline_classification = ["Security", "Bugfix"]

## Ubuntu
ubuntu_maintenance_window_duration    = 3
ubuntu_maintenance_window_cutoff      = 1
ubuntu_maintenance_window_schedule    = "cron(0 0 5 ? 1/1 MON#4 *)"
ubuntu_patching_task_max_concurrency  = "1"
ubuntu_patching_task_max_errors       = "1"
ubuntu_s3_log_prefix                  = "InstallPatchLogs_Ubuntu"
ubuntu_patch_baseline_product         = ["*"]
ubuntu_patch_baseline_section         = ["*"]
ubuntu_patch_baseline_priority        = ["*"]

## CentOS
centos_maintenance_window_duration   = 3
centos_maintenance_window_cutoff     = 1
centos_maintenance_window_schedule   = "cron(0 0 5 ? 1/1 MON#4 *)"
centos_patching_task_max_concurrency = "25%"
centos_patching_task_max_errors      = "1"
centos_s3_log_prefix                 = "InstallPatchLogs_CentOS"
centos_patch_baseline_product        = ["*"]
centos_patch_baseline_classification = ["Security", "Bugfix"]

## RHEL
rhel_maintenance_window_duration   = 3
rhel_maintenance_window_cutoff     = 1
rhel_maintenance_window_schedule   = "cron(0 0 5 ? 1/1 MON#4 *)"
rhel_patching_task_max_concurrency = "25%"
rhel_patching_task_max_errors      = "1"
rhel_s3_log_prefix                 = "InstallPatchLogs_RHEL"
rhel_patch_baseline_product        = ["*"]
rhel_patch_baseline_classification = ["Security", "Bugfix"]

## Windows 2008
windows2008_maintenance_window_duration   = 8
windows2008_maintenance_window_cutoff     = 1
windows2008_maintenance_window_schedule   = "cron(0 0 5 ? 1/1 MON#4 *)"
windows2008_patching_task_max_concurrency = "100%"
windows2008_patching_task_max_errors      = "1"
windows2008_s3_log_prefix                 = "InstallPatchLogs_Windows2008"
windows2008_patch_baseline_product        = ["WindowsServer2008", "WindowsServer2008R2"]
windows2008_patch_baseline_classification = ["SecurityUpdates"]
windows2008_patch_baseline_approve_after_days = 7

## Windows 2012
windows2012_maintenance_window_duration   = 8
windows2012_maintenance_window_cutoff     = 1
windows2012_maintenance_window_schedule   = "cron(0 0 5 ? 1/1 MON#4 *)"
windows2012_patching_task_max_concurrency = "100%"
windows2012_patching_task_max_errors      = "1"
windows2012_s3_log_prefix                 = "InstallPatchLogs_Windows2012"
windows2012_patch_baseline_product        = ["WindowsServer2012", "WindowsServer2012R2"]
windows2012_patch_baseline_classification = ["SecurityUpdates"]
windows2012_patch_baseline_approve_after_days = 7

## Windows 2016
windows2016_maintenance_window_duration   = 8
windows2016_maintenance_window_cutoff     = 1
windows2016_maintenance_window_schedule   = "cron(0 0 5 ? 1/1 MON#4 *)"
windows2016_patching_task_max_concurrency = "100%"
windows2016_patching_task_max_errors      = "1"
windows2016_s3_log_prefix                 = "InstallPatchLogs_Windows2016"
windows2016_patch_baseline_product        = ["WindowsServer2016"]
windows2016_patch_baseline_classification = ["SecurityUpdates"]
windows2016_patch_baseline_approve_after_days = 7