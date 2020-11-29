databag_name = node['emr']['databag_name']
emr_config = data_bag_item(databag_name, node['emr']['databag_item'])

infra_config = data_bag_item(node['infra']['databag_name'], node['infra']['databag_item'])

cluster_names = emr_config['spark_cluster_name']
subnet_ids = emr_config['subnet_id']
chef_environment = infra_config['chef_environment']

knife_config_path = if infra_config['knife_config_path'].nil? || infra_config['knife_config_path'].strip.empty?
                      Chef::Config[:cookbook_path]
                    else
                      infra_config['knife_config_path']
                    end

tags = { 'Environment' => chef_environment,
         'Solution' => 'Periscope',
         'Application' => 'Periscope Suite',
         'Billing' => 'periscope-suite',
         'Tenant' => node['tenant_id'], }

cluster_names.each_with_index do |cluster, index|
  ruby_block 'set security group ids' do
    block do
      master_security_group = get_security_group_id(emr_config['additional_master_security_group'], infra_config['vpc_id'])
      slave_security_group = get_security_group_id(emr_config['additional_slave_security_group'], infra_config['vpc_id'])
      node.set['master_security_group'] = master_security_group
      node.set['slave_security_group'] = slave_security_group
    end
    lazy { notifies :create, 'ruby_block[update_emr_nodes_security_groups]', :immediately }
  end

  ruby_block 'update_emr_nodes_security_groups' do
    block do
      route53 = resources("emr_cluster_create[#{cluster}]")
      route53.additional_master_security_group = node['master_security_group']
      route53.additional_slave_security_group = node['slave_security_group']
    end
  end

  emr_cluster_create cluster do
    subnet subnet_ids[index % subnet_ids.length]
    key_name       infra_config['key_name']
    key_path       infra_config['key_path']
    knife_config_path knife_config_path
    emr_role infra_config['emr_role']
    emr_instance_role infra_config['emr_instance_role']
    script_runner_path infra_config['script_runner_path']
    worker_nodes emr_config['worker_nodes']
    additional_master_security_group lazy { node['master_security_group'] }
    additional_slave_security_group lazy { node['slave_security_group'] }
    jobserver_driver_memory emr_config['jobserver_driver_memory']
    jobserver_log_path emr_config['jobserver_log_path']
    jobserver_install_dir emr_config['jobserver_install_dir']
    env chef_environment
    tags tags
    action :create
  end
end
