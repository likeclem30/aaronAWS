include_recipe 'nginx::default'
databag_name = node['infra']['databag_name']
infra_config = data_bag_item(databag_name, node['infra']['databag_item'])
url_context = node['nginx']['url_context']

template '/etc/nginx/conf.d/pricemonitoring.conf' do
  source 'pricemonitoring.conf.erb'
  variables(url_context: infra_config[url_context])
  mode '644'
  action :create
  notifies :restart, 'service[nginx]'
end
