databag_name   = node['db']['databag_name']
db_config      = data_bag_item(databag_name, node['db']['pv']['databag_item'])
db_secrets = data_bag_item(databag_name, node['db']['secrets'])

env_config = data_bag_item(databag_name, 'env')
hosted_zone_name = env_config['route53_internal_hosted_zone_name']

app_database   = db_config['app_database']
admin_user     = db_secrets['ppv_admin_user']
app_user       = db_secrets['ppv_app_user']

pv_db_users = [admin_user, app_user].join(',')
ppv_web_srv_host_names = []
1.upto(env_config['web_srv_count']) do |count|
  ppv_web_srv_host_names << "#{env_config['ppv_tenant_web_srv_name']}#{count}-srv.#{hosted_zone_name}"
end

hba_configs = []
ppv_web_srv_host_names.each do |ppv_web_srv_host|
  hba_configs.push(type: 'host',
                   db: app_database,
                   user: pv_db_users,
                   addr: ppv_web_srv_host,
                   method: 'md5')
end

node.set['postgresql']['pg_hba'] = node['postgresql']['pg_hba'] + hba_configs
