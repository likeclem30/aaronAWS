component_name = node['ppt-svc']['component_name']
log_directory = node['ppt-svc']['log_directory']

nuget_package component_name do
  install_path node['ppt-svc']['install_path']
  package_source node['ppt-svc']['package_source']
end

template "#{node['ppt-svc']['install_path']}/#{component_name}/config.json" do
  source 'ppt-svc-app-config.erb'
  mode '0644'
  variables(log_directory: log_directory)
end
