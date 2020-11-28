databag_name = node['sb']['databag_name']
sb_svc_config = data_bag_item(databag_name, node['sb']['svc']['databag_item'])
appversions_config = data_bag_item(databag_name, node['sb']['appversions_databag_name'])
sb_db_secrets = data_bag_item(databag_name, node['sb']['db_secrets'])

database_server             = sb_svc_config['database_server']
database_name               = sb_svc_config['database_name']
database_schema             = sb_svc_config['database_schema']

database_username           = sb_db_secrets['sb_app_user']
database_password           = sb_db_secrets['sb_app_password']

sb_svc_comp_version = appversions_config['sb_svc_comp_version']

component_name = node['sb']['svc']['component_name']
log_directory  = "/opt/periscope/#{component_name}/logs"
log_level      = node['sb']['log_level']
app_port       = node['sb']['svc']['app_port']

ppv_yum_package component_name do
  version sb_svc_comp_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/#{component_name}.conf]", :immediately
  notifies :restart, "service[#{component_name}]"
end

template "/opt/periscope/#{component_name}/#{component_name}.conf" do
  source 'sb-svc-app-config.erb'
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
            database_schema: database_schema)
  notifies :restart, "service[#{component_name}]"
end

service component_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end
