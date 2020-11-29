databag_name = node['db']['databag_name']

env_config = data_bag_item(databag_name, 'env')
hosted_zone_name = env_config['route53_internal_hosted_zone_name']

mgmt_srv_host_names = []
1.upto(env_config['mgmt_srv_count']) do |count|
  mgmt_srv_host_names << "#{env_config['ppv_tenant_mgmt_srv_name']}#{count}-srv.#{hosted_zone_name}"
end

hba_configs = []
mgmt_srv_host_names.each do |mgmt_srv_host|
  hba_configs.push(type: 'host',
                   db: 'all',
                   user: 'all',
                   addr: mgmt_srv_host,
                   method: 'md5')
end

node.set['postgresql']['pg_hba'] = node['postgresql']['pg_hba'] + hba_configs
