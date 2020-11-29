# cookbook-emr-cluster
cookbook to create emr cluster using aws cli, provision master node and configure job-server

Requirements
----------------------
aws cli should be installed

Usage
-----------------------

sample recipe to create emr cluster

```ruby
	emr_cluster_create 'price spark server' do
	  subnet 'subnet-0c343627'
	  key_name 			 'P4RNATDefault'
	  emr_role 			 'p4r_role_EMR'
	  emr_instance_role 'p4r_role_devinstance'
	  worker_nodes '2'
	  action :create
	end
```

#### Actions
- `:create` - creates emr cluster

#### Properties
- `name` - name of the step
- `cluster_id` - cluster id to which job-server is added
- `script_runner_path` - s3 bucket path from where script-runner.jar is fetched
- `jobserver_driver_memory` - jobserver driver memory
- `jobserver_log_path` - log path in master node
- `jobserver_install_dir` - directory where all configs and spark-job-server.jar exist
- `release_label` - default emr-4.2.0
- `worker_nodes` - number of worker nodes
- `key_name` - key pair to be used
- `subnet` - subnets where the cluster will be created
- `emr_role` - role to create cluster
- `emr_instance_role` - role for cluster instances
- `master_instance_type` - hardware instance type (default: m3.xlarge)
- `worker_instance_type` - hardware instance type (default: m3.xlarge)
- `additional_master_security_group` - security group for master
- `additional_slave_security_group` - security group for slave 
- `env` - chef environment
- `tags` - tags for the machines
