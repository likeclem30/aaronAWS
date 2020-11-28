databag_name = node.environment
appversions_config = data_bag_item(databag_name, node['monitoring']['versions']['databag_item'])
pcas_config = data_bag_item(databag_name, node['monitoring']['pcas']['databag_item'])
infra_config = data_bag_item(databag_name, node['infra']['databag_item'])

price_monitoring_version = appversions_config['price_monitoring_version']
base = pcas_config['app_domain']

component_name = 'periscope-monitoring'
url_context = node['monitoring']['url_context']
yum_package component_name do
  version price_monitoring_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/public/configvars.js]", :immediately
end

template "/opt/periscope/#{component_name}/public/configvars.js" do
  source node['monitoring']['source_file']
  mode '0644'
  owner component_name
  group component_name
  variables(
    base: base,
    app_context: infra_config[url_context]
  )
end
