databag_name = node['pv-seed-svc']['databag_name']
pv_seed_svc_config = data_bag_item(databag_name, node['pv-seed-svc']['databag_item'])
appversions_config = data_bag_item(databag_name, node['pv-seed-svc']['appversions_databag_name'])
pv_seed_svc_db_secrets = data_bag_item(databag_name, node['pv-seed-svc']['db_secrets'])
pv_seed_svc_app_secrets = data_bag_item(databag_name, node['pv-seed-svc']['app_secrets'])

database_server   = pv_seed_svc_config['database_server']
database_name     = pv_seed_svc_config['database_name']

database_username = pv_seed_svc_db_secrets['ppv_admin_user']
database_password = pv_seed_svc_db_secrets['ppv_admin_password']
csrf_key          = pv_seed_svc_app_secrets['pvseed_csrf_key']

database_schema   = pv_seed_svc_config['database_schema']
token_service_url = pv_seed_svc_config['token_service_url']
logout_path       = pv_seed_svc_config['logout_path']
heartbeat_path    = pv_seed_svc_config['heartbeat_path']
login_url         = pv_seed_svc_config['login_url']
configureusers_path = pv_seed_svc_config['configureusers_path']

pv_seed_svc_comp_version   = appversions_config['pv_seed_svc_comp_version']
pv_seed_svc_assets_version = appversions_config['pv_seed_svc_assets_version']

component_name = node['pv-seed-svc']['component_name']
assets_component_name = node['pv-seed-svc']['assets_package_name']
log_directory  = "/opt/periscope/#{component_name}/logs"
log_level      = node['pv-seed-svc']['log_level']
app_port       = node['pv-seed-svc']['app_port']

ppv_yum_package assets_component_name do
  version pv_seed_svc_assets_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{assets_component_name}/public/config.js]", :immediately
end

template "/opt/periscope/#{assets_component_name}/public/config.js" do
  source 'pv-seed-assets-config.erb'
  mode '0644'
  owner assets_component_name
  group assets_component_name
  variables(
    logout_path: logout_path,
    heartbeat_path: heartbeat_path,
    configureusers_path: configureusers_path
  )
end

ppv_yum_package component_name do
  version pv_seed_svc_comp_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/#{component_name}.conf]", :immediately
  notifies :restart, "service[#{component_name}]"
end

template "/opt/periscope/#{component_name}/#{component_name}.conf" do
  source 'pv-seed-svc-app-config.erb'
  mode '0644'
  owner component_name
  group component_name
  variables(app_port: app_port,
            log_directory: log_directory,
            log_level: log_level,
            database_server: database_server,
            database_name: database_name,
            database_username: database_username,
            database_password: database_password,
            database_schema: database_schema,
            token_service_url: token_service_url,
            login_url: login_url,
            csrf_key: csrf_key)
  notifies :restart, "service[#{component_name}]"
end

service component_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end
