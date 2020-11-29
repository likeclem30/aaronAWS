databag_name = node['price']['databag_name']
config = data_bag_item(databag_name, node['price']['dimensiondataservice']['databag_item'])
versions = data_bag_item(databag_name, node['price']['services']['databag_item'])
db_secrets = data_bag_item(databag_name, node['db']['secrets'])
db_config = data_bag_item(databag_name, node['price']['db']['databag_item'])

dimensiondataservice_version = versions['dimensiondataservice_version']
app_port = config['app_port']
log_format = config['log_format']
log_level = config['log_level']
db_port = db_config['db_port']
db_instance = db_config['db_instance']
db_server = db_config['db_server']
db_username = db_secrets['app_user']
db_password = db_secrets['app_password']
metadata_endpoint = config['metadata_endpoint']

component_name = 'price-dimensiondataservice'
log_directory = "/opt/periscope/#{component_name}/logs"

yum_package component_name do
  version dimensiondataservice_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/#{component_name}.conf]", :immediately
  notifies :restart, "service[#{component_name}]"
end

template "/opt/periscope/#{component_name}/#{component_name}.conf" do
  source 'dimensiondataservice_config.erb'
  mode '0644'
  owner component_name
  group component_name
  variables(app_port: app_port,
            log_format: log_format,
            db_port: db_port,
            db_instance: db_instance,
            db_server: db_server,
            db_username: db_username,
            db_password: db_password,
            metadata_endpoint: metadata_endpoint,
            log_directory: log_directory,
            log_level: log_level)
  notifies :restart, "service[#{component_name}]"
end

service component_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end
