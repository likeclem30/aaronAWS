databag_name = node['ppt']['databag_name']
appversions_config = data_bag_item(databag_name, node['ppt']['appversions_databag_name'])

ppt_svc_comp_version = appversions_config['ppt_svc_comp_version']

component_name = node['ppt']['component_name']
app_port = node['ppt']['app_port']
chart_image_path = node['ppt']['chart_image_path']
log_directory = node['ppt']['log_directory']

ppv_yum_package component_name do
  version ppt_svc_comp_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/#{component_name}.conf]", :immediately
  notifies :restart, "service[#{component_name}]"
end

template "/opt/periscope/#{component_name}/#{component_name}.conf" do
  source 'ppt-svc-app-config.erb'
  mode '0644'
  owner component_name
  group component_name
  variables(app_port: app_port,
            chart_image_path: chart_image_path,
            log_directory: log_directory)
  notifies :restart, "service[#{component_name}]"
end

service component_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end
