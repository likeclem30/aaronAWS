require 'uri'

databag_name = node.environment
databag_name = 'dem-tenant1' if node.environment == 'dem'
appversions_config = data_bag_item(databag_name, node['monitoring']['versions']['databag_item'])
pcas_config = data_bag_item(databag_name, node['monitoring']['pcas']['databag_item'])
infra_config = data_bag_item(databag_name, node['infra']['databag_item'])

monitoring_services = node['monitoring']['services']

monitoring_version = appversions_config['monitoring_version']

component_name = node['monitoring']['component']['name']
url_context = node['monitoring']['url_context']

base = "https://#{pcas_config['app_domain']}#{infra_config[url_context]}/"

services = monitoring_services.map do |service|
  {
    'name' => service['name'],
    'url' => URI.join(base, service['url']).to_s,
  }
end

yum_package component_name do
  version monitoring_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/public/configvars.js]", :immediately
end

template "/opt/periscope/#{component_name}/public/configvars.js" do
  source node['monitoring']['source_file']
  mode '0644'
  owner component_name
  group component_name
  variables(
    services: services
  )
end
