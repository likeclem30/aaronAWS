template "/etc/yum.repos.d/#{node['nginx']['repo_name']}.repo" do
  action :create
  source 'nginx.repo.erb'
  mode 0644
  variables(repo_name: node['nginx']['repo_name'],
            repo_url: node['nginx']['repo_url'],
            gpgcheck: node['nginx']['gpgcheck'],
            is_enabled: node['nginx']['enabled'])
end

yum_package 'nginx' do
  action :install
  version node['nginx']['version-release']
  flush_cache [:before]
end

file '/etc/nginx/conf.d/default.conf' do
  action :delete
  notifies :restart, 'service[nginx]'
end

service 'nginx' do
  action [:enable, :start]
  supports start: true, stop: true, restart: true
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  mode '644'
  variables(
    user: node['nginx']['user'],
    group: node['nginx']['group'],
    base_route: node['nginx']['base_route']
  )
  action :create
  notifies :restart, 'service[nginx]'
end

template '/etc/nginx/conf.d/gzip.conf' do
  source 'gzip.conf.erb'
  mode '644'
  action :create
  notifies :restart, 'service[nginx]'
end

template '/etc/nginx/mime.types' do
  source 'mime.types.erb'
  mode '644'
  action :create
  notifies :restart, 'service[nginx]'
end
