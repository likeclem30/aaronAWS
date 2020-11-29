databag_name = node['it']['databag_name']

component_name = node['it']['server']['component_name']

appversions_databag = data_bag_item(databag_name, 'appversions')
it_databag = data_bag_item(databag_name, 'it')

db_secrets = data_bag_item(databag_name, node['it']['db_secrets'])
app_secrets = data_bag_item(databag_name, node['it']['app_secrets'])

database_username   = db_secrets['it_app_user']
database_password   = db_secrets['it_app_password']

ppv_yum_package component_name do
  version appversions_databag['impact_tracker_server_version']
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/#{component_name}.conf]", :immediately
  notifies :restart, "service[#{component_name}]"
end

log_directory = node['it']['server']['log_directory']
server_address = node['it']['server']['server_address']
actions_table_name = node['it']['server']['actions_table_name']
log_level = node['it']['server']['log_level']
csrf_key = app_secrets['it_csrf_key']

db_connection_string = "user=#{database_username} password=#{database_password} host=#{it_databag['database_server']} port=#{it_databag['database_port']} "\
  "dbname=#{it_databag['database_name']} search_path=#{it_databag['database_schema']} sslmode=disable"
token_service_url = it_databag['token_service_url']
login_page_url = it_databag['login_page_url']

template "/opt/periscope/#{component_name}/#{component_name}.conf" do
  source 'impact-tracker-server-config.conf.erb'
  mode '0644'
  owner component_name
  group component_name
  variables(
    log_directory: log_directory,
    server_address: server_address,
    actions_table_name: actions_table_name,
    db_connection_string: db_connection_string,
    token_service_url: token_service_url,
    login_page_url: login_page_url,
    log_level: log_level,
    it_csrf_key: csrf_key
  )
  notifies :restart, "service[#{component_name}]"
end

service component_name do
  supports start: true, stop: true, restart: true, status: true
  action [:enable, :restart]
end
