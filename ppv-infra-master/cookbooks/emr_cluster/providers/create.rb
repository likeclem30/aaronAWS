require 'json'
require 'open3'

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = new_resource.class.new(new_resource.name)
end

def define_resource_requirements
  verify_aws_exist
  verify_knife_exist
end

def verify_aws_exist
  requirements.assert(:create) do |a|
    a.assertion { cmd_success?('which aws') }
    a.failure_message('aws is not in path')
    a.whyrun('Assuming aws will be installed')
  end
end

def verify_knife_exist
  requirements.assert(:create) do |a|
    a.assertion { cmd_success?('which knife') }
    a.failure_message('knife is not in path')
    a.whyrun('Assuming knife will be installed')
  end
end

def formatted_tags
  return "'Environment=#{new_resource.env}'" if new_resource.tags.empty?
  tags = new_resource.tags.keys.map { |key| "'#{key}=#{new_resource.tags[key]}'" }
  tags.join(' ')
end

def create_cluster_command
  "aws emr create-cluster --name '#{new_resource.name}' --release-label #{new_resource.release_label} "\
    "--tags #{formatted_tags} "\
    "--instance-groups InstanceCount=1,Name=sparkMaster,InstanceGroupType=MASTER,InstanceType=#{new_resource.master_instance_type} "\
    "InstanceCount=#{new_resource.worker_nodes},Name=sparkSlave,InstanceGroupType=CORE,InstanceType=#{new_resource.worker_instance_type} "\
    '--applications Name=Spark Name=Ganglia '\
    "--ec2-attributes KeyName=#{new_resource.key_name},SubnetId=#{new_resource.subnet},"\
    "AdditionalMasterSecurityGroups=#{new_resource.additional_master_security_group},"\
    "AdditionalSlaveSecurityGroups=#{new_resource.additional_slave_security_group},InstanceProfile=#{new_resource.emr_instance_role} "\
    '--region us-east-1 '\
    "--service-role #{new_resource.emr_role} "
end

use_inline_resources
action :create do
  clusterid = ''
  if !cluster_exist?(new_resource.name.to_s)

    stdout, _stderr, _status = Open3.capture3(create_cluster_command)

    create_cluster_response = JSON.parse(stdout)
    clusterid = create_cluster_response['ClusterId']
    p "Cluster ID : #{clusterid}"

  else
    clusterid = get_cluster_id_by_name(new_resource.name.to_s)
  end

  setup_spark_cluster(new_resource.env, new_resource.name, clusterid, new_resource.key_name,
                      new_resource.key_path, new_resource.knife_config_path)
end
