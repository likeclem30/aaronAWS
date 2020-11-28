include_recipe 'nginx::default'

databag_name = node['infra']['databag_name']
infra_config = data_bag_item(databag_name, node['infra']['databag_item'])

template '/etc/nginx/conf.d/01_it_server.conf' do
  source '01_it_server.conf.erb'
  mode '644'
  variables(
    url_context: infra_config['app_context']
  )
  action :create
  notifies :restart, 'service[nginx]'
end

file '/etc/nginx/conf.d/default.conf' do
  action :delete
  notifies :restart, 'service[nginx]'
end
