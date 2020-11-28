# Install nginx
include_recipe 'mash-ipwl-ppv::install_nginx'
# Install lua modules
include_recipe 'mash-ipwl-ppv::install_lua_modules'
# Generate all config files for nginx ipwl in the mount folder /etc/nginx-ipwl-config-generated/
include_recipe 'mash-ipwl-ppv::generate_nginx_ipwl_config'

if node['mash-ipwl-ppv']['config_validation']
	 #Start a docker container to test the config files of nginx
	include_recipe 'mash-ipwl-ppv::run_nginx_ipwl_container'
end



nginx_dir = node['mash-ipwl-ppv']['nginx_dir']
nginx_dir_temp = node['mash-ipwl-ppv']['nginx_dir_temp']

# Clean old nginx config sites-enabled folder
[nginx_dir+'/lua_files', nginx_dir+'/sites-enabled'].each do |nginx_subdir|
	execute 'clean_site_enabled_folder' do
		command "rm -rf #{nginx_subdir}/*"
	end
end

# Copy all files from nginx ipwl config folder
execute 'cp_nginx_conf' do
  command "cp -R #{nginx_dir_temp}/* #{nginx_dir}"
  notifies :reload, 'service[nginx]'
end

service 'nginx' do
  action :nothing
  reload_command "/usr/sbin/nginx -s reload"
  supports :status => true, :start => true, :stop => true, :reload => true
end

