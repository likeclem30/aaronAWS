actions	:create
default_action	:create

property :name, String, name_property: true
property :release_label,     String, default: 'emr-4.2.0'
property :worker_nodes,      String, regex: /^[0-9]+$/
property :key_name, String, required: true
property :key_path, String, required: true
property :knife_config_path, String, required: true
property :subnet, String, required: true
property :emr_role, String, required: true
property :emr_instance_role, String, required: true
property :master_instance_type, String, default: 'm3.xlarge'
property :worker_instance_type, String, default: 'm3.xlarge'
property :additional_master_security_group, String, required: true
property :additional_slave_security_group, String, required: true
property :script_runner_path, String, required: true
property :jobserver_driver_memory, String, default: '1GB'
property :jobserver_log_path, String, default: '/var/log/spark-jobserver'
property :jobserver_install_dir, String, required: true
property :env, String, required: true
property :tags, Hash, default: {}
