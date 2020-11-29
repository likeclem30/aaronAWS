include_recipe 'nginx::default'
databag_name = node['infra']['databag_name']
infra_config = data_bag_item(databag_name, node['infra']['databag_item'])

template '/etc/nginx/conf.d/priceweb.conf' do
  source 'priceweb.conf.erb'
  variables(app_context: infra_config['app_context'])
  mode '644'
  action :create
  notifies :restart, 'service[nginx]'
end
