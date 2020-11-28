databag_name       = node['db']['databag_name']
db_config          = data_bag_item(databag_name, node['db']['sb']['databag_item'])
db_secrets = data_bag_item(databag_name, node['db']['secrets'])

env_config = data_bag_item(databag_name, 'env')
hosted_zone_name = env_config['route53_internal_hosted_zone_name']

app_database       = db_config['app_database']

app_user           = db_secrets['sb_app_user']
admin_user         = db_secrets['sb_admin_user']

sb_db_users = [admin_user, app_user].join(',')

svc_srv_host_names = []
1.upto(env_config['svc_srv_count']) do |count|
  svc_srv_host_names << "#{env_config['ppv_tenant_svc_srv_name']}#{count}-srv.#{hosted_zone_name}"
end

hba_configs = []
svc_srv_host_names.each do |svc_srv_host_name|
  hba_configs.push(type: 'host',
                   db: app_database,
                   user: sb_db_users,
                   addr: svc_srv_host_name,
                   method: 'md5')
end

node.set['postgresql']['pg_hba'] = node['postgresql']['pg_hba'] + hba_configs
