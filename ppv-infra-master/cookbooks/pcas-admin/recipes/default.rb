databag_name = node['pcas-admin']['databag_name']
pcas_admin_config = data_bag_item(databag_name, node['pcas-admin']['databag_item'])
appversions_config = data_bag_item(databag_name, node['pcas-admin']['appversions_databag_name'])
pcas_app_secrets = data_bag_item(databag_name, node['pcas-admin']['secrets'])

auth0_token       = pcas_app_secrets['admin_app_auth0_token']
csrf_key          = pcas_app_secrets['admin_app_csrf_key']
client_id = pcas_app_secrets['auth0_client_id']

tokenservice_url  = pcas_admin_config['tokenservice_url']
logout_path       = pcas_admin_config['logout_path']
performance_path  = pcas_admin_config['performance_path']
actionworkflow_path = pcas_admin_config['actionworkflow_path']
price_path = pcas_admin_config['price_path']
heartbeat_path    = pcas_admin_config['heartbeat_path']
login_url         = pcas_admin_config['login_url']
aws_command = pcas_admin_config['aws_command']
s3_usersync_bucket = pcas_admin_config['s3_usersync_bucket']
create_user_endpoint = pcas_admin_config['create_user_endpoint']
password_reset_endpoint = pcas_admin_config['password_reset_endpoint']
connection_name = pcas_admin_config['connection_name']

pcas_admin_comp_version   = appversions_config['pcas_admin_comp_version']
pcas_admin_assets_version = appversions_config['pcas_admin_assets_version']

component_name = node['pcas-admin']['component_name']
log_directory  = "/opt/periscope/#{component_name}/logs"
app_port       = node['pcas-admin']['app_port']

ppv_yum_package node['pcas-admin']['assets_package_name'] do
  version pcas_admin_assets_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/public/config.js]", :immediately
end

template "/opt/periscope/#{component_name}/public/config.js" do
  source 'pcas-admin-assets-config.erb'
  mode '0644'
  owner component_name
  group component_name
  variables(
    logout_path: logout_path,
    heartbeat_path: heartbeat_path,
    performance_path: performance_path,
    actionworkflow_path: actionworkflow_path,
    price_path: price_path
  )
end

ppv_yum_package component_name do
  version pcas_admin_comp_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/#{component_name}.conf]", :immediately
  notifies :restart, "service[#{component_name}]"
end

template "/opt/periscope/#{component_name}/#{component_name}.conf" do
  source 'pcas-admin-app-config.erb'
  mode '0644'
  owner component_name
  group component_name
  variables(app_port: app_port,
            log_directory: log_directory,
            auth0_token: auth0_token,
            tokenservice_url: tokenservice_url,
            csrf_key: csrf_key,
            login_url: login_url,
            logout_url: logout_path,
            aws_command: aws_command,
            s3_usersync_bucket: s3_usersync_bucket,
            client_id: client_id,
            create_user_endpoint: create_user_endpoint,
            password_reset_endpoint: password_reset_endpoint,
            connection_name: connection_name)
  notifies :restart, "service[#{component_name}]"
end

service component_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end
