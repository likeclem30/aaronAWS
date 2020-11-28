databag_name = node['token-svc']['databag_name']
token_svc_config = data_bag_item(databag_name, node['token-svc']['databag_item'])
appversions_config = data_bag_item(databag_name, node['token-svc']['appversions_databag_name'])

token_svc_app_secrets = data_bag_item(databag_name, node['token-svc']['app_secrets'])

auth_secret = token_svc_app_secrets['auth_secret']
periscope_secret = token_svc_app_secrets['periscope_secret']

sliding_exp = token_svc_config['sliding_exp']
cz = token_svc_config['cz']

token_svc_comp_version = appversions_config['token_svc_comp_version']

token_service_name = node['token-svc']['comp_name']
token_service_port = node['token-svc']['app_port']
login_comp_name = node['token-svc']['comp_name']

log_directory = "/opt/periscope/#{login_comp_name}/logs"

ppv_yum_package token_service_name do
  version token_svc_comp_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{token_service_name}/#{token_service_name}.conf]", :immediately
  notifies :restart, "service[#{token_service_name}]"
end

template "/opt/periscope/#{token_service_name}/#{token_service_name}.conf" do
  source 'token-service-config.erb'
  mode '0644'
  owner token_service_name
  group token_service_name
  variables(token_service_port: token_service_port,
            sliding_exp: sliding_exp,
            auth_secret:  auth_secret,
            periscope_secret:  periscope_secret,
            log_directory: log_directory,
            cz: cz)
  notifies :restart, "service[#{token_service_name}]"
end

service token_service_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end
