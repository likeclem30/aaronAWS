databag_name = node['price']['databag_name']
config = data_bag_item(databag_name, node['price']['calcenginedataservice']['databag_item'])
versions = data_bag_item(databag_name, node['price']['services']['databag_item'])

calcenginedataservice_version = versions['calcenginedataservice_version']
app_port = config['app_port']
log_format = config['log_format']
factdata_endpoint = config['factdata_endpoint']
competitor_endpoint = config['competitor_endpoint']
log_level = config['log_level']

component_name = 'price-calcenginedataservice'
log_directory = "/opt/periscope/#{component_name}/logs"

yum_package component_name do
  version calcenginedataservice_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/#{component_name}.conf]", :immediately
  notifies :restart, "service[#{component_name}]"
end

template "/opt/periscope/#{component_name}/#{component_name}.conf" do
  source 'calcenginedataservice_config.erb'
  mode '0644'
  owner component_name
  group component_name
  variables(app_port: app_port,
            log_format: log_format,
            factdata_endpoint: factdata_endpoint,
            competitor_endpoint: competitor_endpoint,
            log_directory: log_directory,
            log_level: log_level)
  notifies :restart, "service[#{component_name}]"
end

service component_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end
