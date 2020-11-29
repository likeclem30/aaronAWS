databag_name = node['it_admin']['databag_name']

component_name = node['it_admin']['server']['component_name']

appversions_databag = data_bag_item(databag_name, 'appversions')
it_admin_databag = data_bag_item(databag_name, 'it-admin')

db_secrets = data_bag_item(databag_name, 'db-secrets')
database_username   = db_secrets['it_admin_user']
database_password   = db_secrets['it_admin_password']

ppv_yum_package component_name do
  version appversions_databag['itracker_admin_service_version']
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/#{component_name}.conf]", :immediately
  notifies :restart, "service[#{component_name}]"
end

token_service_url = it_admin_databag['token_service_url']
login_url = it_admin_databag['login_url']
database_server = it_admin_databag['database_server']

app_port = node['it_admin']['server']['app_port']
log_directory = node['it_admin']['server']['log_directory']
csrf_key = node['it_admin']['server']['csrf_key']
database_schema = node['it_admin']['server']['database_schema']
database_name = node['it_admin']['server']['database_name']

template "/opt/periscope/#{component_name}/#{component_name}.conf" do
  source 'itracker-admin-service.conf.erb'
  mode '0644'
  owner component_name
  group component_name
  variables(
    app_port: app_port,
    log_directory: log_directory,
    token_service_url: token_service_url,
    csrf_key: csrf_key,
    login_url: login_url,
    database_server: database_server,
    database_schema: database_schema,
    database_name: database_name,
    database_username: database_username,
    database_password: database_password,
  )
  notifies :restart, "service[#{component_name}]"
end

service component_name do
  supports start: true, stop: true, restart: true, status: true
  action [:enable, :restart]
end
