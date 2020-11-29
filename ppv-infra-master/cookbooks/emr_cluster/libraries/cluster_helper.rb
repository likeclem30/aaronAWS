require 'json'
require 'open3'

def cluster_exist?(name)
  list_cluster_command = 'aws emr list-clusters'
  stdout, _stdeerr, _status = Open3.capture3(list_cluster_command)
  list_cluster_response = JSON.parse(stdout)
  count = list_cluster_response['Clusters'].count do |cluster|
    (cluster['Status']['State'] == 'RUNNING' || cluster['Status']['State'] == 'WAITING') && cluster['Name'] == name
  end
  count > 0
end

def cluster_waiting?(name)
  list_cluster_command = 'aws emr list-clusters'
  stdout, _stdeerr, _status = Open3.capture3(list_cluster_command)
  list_cluster_response = JSON.parse(stdout)
  count = list_cluster_response['Clusters'].count { |cluster| cluster['Status']['State'] == 'WAITING' && cluster['Name'] == name }
  count > 0
end

def cluster_running?(state)
  return unless state.include?('TERMINATING') || state.include?('TERMINATED')
  raise "cluster #{state}"
end

def get_cluster_id_by_name(cluster_name)
  list_cluster_command = 'aws emr list-clusters'
  stdout, _stdeerr, _status = Open3.capture3(list_cluster_command)
  list_cluster_res = JSON.parse(stdout)
  cluster = list_cluster_res['Clusters'].select do |c|
    (c['Status']['State'] == 'RUNNING' || c['Status']['State'] == 'WAITING') && c['Name'] == cluster_name
  end
  cluster[0]['Id']
end

def get_instances(clusterid, type)
  list_instance_command = "aws emr list-instances --cluster-id #{clusterid} --instance-group-types #{type}"
  stdout, _stdeerr, _status = Open3.capture3(list_instance_command)
  list_instance_response = JSON.parse(stdout)
  list_instance_response['Instances']
end

def bootstrap_cluster_instance(ipaddress, name, role, env, keyname, keypath, knife_config_path)
  bootstrap_command = "knife bootstrap #{ipaddress} "\
    "-N '#{name}' "\
    "-r 'role[#{role}]' "\
    "-E #{env} "\
    '-x hadoop '\
    "-i #{keypath}/#{keyname}.pem "\
    '--sudo -y'

  bash "bootstrap #{ipaddress} with name #{name} and environment #{env}" do
    cwd knife_config_path
    code <<-EOH
      #{bootstrap_command}
      EOH
  end
end

def tag_ec2instance_with_name(instance_id, name)
  tag_instance_command = "aws ec2 create-tags --resources #{instance_id} --tags Key=Name,Value=#{name}"

  bash "tag #{instance_id} with name #{name}" do
    code <<-EOH
      #{tag_instance_command}
      EOH
  end
end

def configure_master_instance(env, name, clusterid, keyname, keypath, knife_config_path)
  instances = get_instances(clusterid, 'MASTER')
  if instances[0]['Status']['State'] != 'RUNNING'
    raise "master instance not running. State : #{instances[0]['Status']['State']}"
  end
  name = "#{name}-master-srv"
  bootstrap_cluster_instance(instances[0]['PrivateIpAddress'], name, 'price-master-prov',
                             env, keyname, keypath, knife_config_path)
  tag_ec2instance_with_name(instances[0]['Ec2InstanceId'], name)
end

def configure_slave_instances(env, name, clusterid, keyname, keypath, knife_config_path)
  instances = get_instances(clusterid, 'CORE')

  instances.each_with_index do |instance, index|
    private_ip_address = instance['PrivateIpAddress']

    if instance['Status']['State'] != 'RUNNING'
      Chef::Log.info("slave instance #{private_ip_address} not running."\
      " State : #{instance['Status']['State']}")
      next
    end
    instance_name = "#{name}-slave#{index}-srv"
    bootstrap_cluster_instance(instance['PrivateIpAddress'], instance_name, 'price-slave-prov',
                               env, keyname, keypath, knife_config_path)
    tag_ec2instance_with_name(instance['Ec2InstanceId'], instance_name)
  end
end

def setup_spark_cluster(env, name, clusterid, keyname, keypath, knife_config_path)
  describe_cluster_command = "aws emr describe-cluster --cluster-id #{clusterid}"
  state = ''
  while state != 'WAITING' && state != 'RUNNING'
    cluster_running?(state)
    stdout, _stdeerr, _status = Open3.capture3(describe_cluster_command)
    describe_cluster_response = JSON.parse(stdout)
    state = describe_cluster_response['Cluster']['Status']['State']
    print '.'
    sleep(5)
  end

  configure_master_instance(env, name, clusterid, keyname, keypath, knife_config_path)
  configure_slave_instances(env, name, clusterid, keyname, keypath, knife_config_path)
end

def get_security_group_id(name, vpc_id)
  describe_security_groups_command = "aws ec2 describe-security-groups --filters Name=vpc-id,Values='#{vpc_id}'"
  stdout, _stdeerr, _status = Open3.capture3(describe_security_groups_command)
  describe_security_groups_response = JSON.parse(stdout)
  security_groups = describe_security_groups_response['SecurityGroups']
  security_groups.select { |s| s['GroupName'] == name && s['VpcId'] == vpc_id }[0]['GroupId']
end
