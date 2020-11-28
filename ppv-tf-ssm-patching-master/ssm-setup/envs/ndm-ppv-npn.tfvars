## Generic
ssm_patching_bucket_name = "ppv-npn-ssm-patching-logs"

## Maintenance Windows
mw_patching_group_one_name = "mw-patching-group-1"
mw_patching_group_one_schedule = "cron(0 0 10 ? 1/1 SUN#2 *)"
mw_patching_group_one_duration = 6
mw_patching_group_one_cutoff = 3

mw_patching_group_two_name = "mw-patching-group-2"
mw_patching_group_two_schedule = "cron(0 0 13 ? 1/1 SUN#2 *)"
mw_patching_group_two_duration = 6
mw_patching_group_two_cutoff = 3

maintenance_task_max_concurrency = "100%"
maintenance_task_max_errors      = "20%"
patching_group1_s3_log_prefix    = "InstallPatchLogs_PatchGroup1"
patching_group2_s3_log_prefix    = "InstallPatchLogs_PatchGroup2"

## Amazon Linux
amazon_linux_patch_baseline_product        = ["*"]
amazon_linux_patch_baseline_classification = ["Security", "Bugfix"]

## Amazon Linux 2
amazon_linux_2_patch_baseline_product        = ["*"]
amazon_linux_2_patch_baseline_classification = ["Security", "Bugfix"]

## Ubuntu
ubuntu_patch_baseline_product         = ["*"]
ubuntu_patch_baseline_section         = ["*"]
ubuntu_patch_baseline_priority        = ["Required", "Important", "Standard", "Optional", "Extra"]

## CentOS
centos_patch_baseline_product        = ["*"]
centos_patch_baseline_classification = ["Security", "Bugfix"]

## RHEL
rhel_patch_baseline_product        = ["*"]
rhel_patch_baseline_classification = ["Security", "Bugfix"]

## Windows 2008
windows2008_patch_baseline_product        = ["WindowsServer2008", "WindowsServer2008R2"]
windows2008_patch_baseline_classification = ["SecurityUpdates"]
windows2008_patch_baseline_approve_after_days = 1

## Windows 2012
windows2012_patch_baseline_product        = ["WindowsServer2012", "WindowsServer2012R2"]
windows2012_patch_baseline_classification = ["SecurityUpdates" ]
windows2012_patch_baseline_approve_after_days = 1

## Windows 2016
windows2016_patch_baseline_product        = ["WindowsServer2016"]
windows2016_patch_baseline_classification = ["SecurityUpdates"]
windows2016_patch_baseline_approve_after_days = 1