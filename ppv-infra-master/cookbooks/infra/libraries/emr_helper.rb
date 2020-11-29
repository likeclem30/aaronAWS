require 'json'
require 'open3'

def add_master_to_elb(cluster_name, elb)
  cluster_id = get_cluster_id_by_name(cluster_name)
  instance_id = get_master_instance_id(cluster_id)
  add_master_to_elb_command = "aws elb register-instances-with-load-balancer --load-balancer-name #{elb} --instances #{instance_id}"
  stdout, _stdeerr, _status = Open3.capture3(add_master_to_elb_command)
end

def get_cluster_id_by_name(cluster_name)
  list_cluster_command = 'aws emr list-clusters'
  stdout, _stdeerr, _status = Open3.capture3(list_cluster_command)
  list_cluster_res = JSON.parse(stdout)
  cluster = list_cluster_res['Clusters'].select { |c| (c['Status']['State'] == 'RUNNING' || c['Status']['State'] == 'WAITING') && c['Name'] == cluster_name }
  cluster[0]['Id']
end

def get_master_instance_id(cluster_id)
  list_instance_command = "aws emr list-instances --cluster-id #{cluster_id} --instance-group-types MASTER"
  stdout, _stdeerr, _status = Open3.capture3(list_instance_command)
  list_instance_response = JSON.parse(stdout)
  list_instance_response['Instances'][0]['Ec2InstanceId']
end
