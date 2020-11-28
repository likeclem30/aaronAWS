databag_name       = node['db']['databag_name']
db_config          = data_bag_item(databag_name, node['db']['it']['databag_item'])

env_config = data_bag_item(databag_name, 'env')
hosted_zone_name = env_config['route53_internal_hosted_zone_name']

app_database = db_config['app_database']
db_secrets = data_bag_item(databag_name, node['db']['secrets'])

admin_user     = db_secrets['it_admin_user']
app_user       = db_secrets['it_app_user']

it_db_users = [admin_user, app_user].join(',')
it_web_srv_host_names = []
1.upto(env_config['web_srv_count']) do |count|
  it_web_srv_host_names << "#{env_config['ppv_tenant_web_srv_name']}#{count}-srv.#{hosted_zone_name}"
end

hba_configs = []
it_web_srv_host_names.each do |it_web_srv_host|
  hba_configs.push(type: 'host',
                   db: app_database,
                   user: it_db_users,
                   addr: it_web_srv_host,
                   method: 'md5')
end

node.set['postgresql']['pg_hba'] = node['postgresql']['pg_hba'] + hba_configs
