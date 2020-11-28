databag_name = node['price']['databag_name']
config = data_bag_item(databag_name, node['price']['priceservice']['databag_item'])
web_config = data_bag_item(databag_name, node['price']['web']['databag_item'])
versions = data_bag_item(databag_name, node['price']['services']['databag_item'])
app_secrets = data_bag_item(databag_name, node['app']['secrets'])

priceservice_version = versions['priceservice_version']
pricefrontend_version = versions['price_frontend_version']
login_route = web_config['login_route']
logout_route = web_config['logout_route']
base_route = web_config['base_route']

app_port = config['app_port']
log_format = config['log_format']
log_level = config['log_level']
query_endpoint = config['query_endpoint']
configuration_endpoint = config['configuration_endpoint']
planning_endpoint = config['planning_endpoint']
workflow_endpoint = config['workflow_endpoint']
dimensiondata_endpoint = config['dimensiondata_endpoint']
tokenservice_endpoint = config['tokenservice_endpoint']
metadata_endpoint = config['metadata_endpoint']
calcenginedata_endpoint = config['calcenginedata_endpoint']
competitor_endpoint = config['competitor_endpoint']
csrf_key = app_secrets['csrf_key']

component_name = 'price-web'
log_directory = "/opt/periscope/#{component_name}/logs"

yum_package component_name do
  version priceservice_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/#{component_name}.conf]", :immediately
  notifies :restart, "service[#{component_name}]"
end

yum_package 'price_frontend' do
  version pricefrontend_version
  flush_cache [:before]
end

template '/opt/periscope/price_frontend/public/configvars.js' do
  source 'priceweb_configvars.erb'
  mode '0644'
  owner component_name
  group component_name
  variables(login_route: login_route,
            logout_route: logout_route,
            base_route: base_route)
end

template "/opt/periscope/#{component_name}/#{component_name}.conf" do
  source 'priceservice_config.erb'
  mode '0644'
  owner component_name
  group component_name
  variables(app_port: app_port,
            log_format: log_format,
            query_endpoint: query_endpoint,
            configuration_endpoint: configuration_endpoint,
            planning_endpoint: planning_endpoint,
            workflow_endpoint: workflow_endpoint,
            dimensiondata_endpoint: dimensiondata_endpoint,
            tokenservice_endpoint: tokenservice_endpoint,
            csrf_key: csrf_key,
            log_directory: log_directory,
            metadata_endpoint: metadata_endpoint,
            calcenginedata_endpoint: calcenginedata_endpoint,
            competitor_endpoint: competitor_endpoint,
            log_level: log_level)
  notifies :restart, "service[#{component_name}]"
end

service component_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end
