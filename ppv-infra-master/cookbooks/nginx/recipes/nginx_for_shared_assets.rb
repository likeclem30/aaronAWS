include_recipe 'nginx::default'

databag_name = node['infra']['databag_name']
infra_config = data_bag_item(databag_name, node['infra']['databag_item'])

url_context = node['nginx']['url_context']

template '/etc/nginx/conf.d/00_shared_assets.conf' do
  source '00_shared_assets.conf.erb'
  mode '644'
  variables(
    url_context: infra_config[url_context],
  )
  action :create
  notifies :restart, 'service[nginx]'
end

file '/etc/nginx/conf.d/default.conf' do
  action :delete
  notifies :restart, 'service[nginx]'
end
