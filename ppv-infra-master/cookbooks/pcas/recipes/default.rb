databag_name = node['pcas']['databag_name']
pcas_config = data_bag_item(databag_name, node['pcas']['databag_item'])
appversions_config = data_bag_item(databag_name, node['pcas']['appversions_databag_name'])
pcas_app_secrets = data_bag_item(databag_name, node['pcas']['secrets'])

csrf_key                      = pcas_app_secrets['login_csrf_key']
auth0_client_id               = pcas_app_secrets['auth0_client_id']

env_config = data_bag_item(databag_name, node['pcas']['env_databag_name'])

static_assets_root_dir        = pcas_config['static_assets_root_dir']
auth0_domain                  = pcas_config['auth0_domain']
cz                            = pcas_config['cz']
tableau_logout_url            = pcas_config['tableau_logout_url']
auth0_logout_url              = pcas_config['auth0_logout_url']
token_service_base_url        = pcas_config['token_service_base_url']
app_domain                    = pcas_config['app_domain']
login_redirection_timeout     = pcas_config['login_redirection_timeout']

app_config = node['pcas']['app_config']

pcas_role_config = pcas_config[app_config]
admin_node_roles = env_config['machine_runlist']['ppv_tenant_mgmt_srv_runlist']

login_route                   = pcas_role_config['login_route']
redirect_route                = pcas_role_config['redirect_route']
default_login_redirection_url = pcas_role_config['default_login_redirection_url']

pcas_comp_version = appversions_config['pcas_comp_version']
pcas_assets_version = appversions_config['pcas_assets_version']

server_port = node['pcas']['server_port']
login_comp_name = node['pcas']['comp_name']['login']
log_directory = "/opt/periscope/#{login_comp_name}/logs"

ppv_yum_package node['pcas']['assets_package_name'] do
  version pcas_assets_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{login_comp_name}/public/javascripts/configvars.js]", :immediately
end

template "/opt/periscope/#{login_comp_name}/public/javascripts/configvars.js" do
  source 'login-web-assets-config.erb'
  mode '0644'
  owner login_comp_name
  group login_comp_name
  variables(auth0_client_id: auth0_client_id,
            auth0_domain: auth0_domain,
            login_route: login_route,
            redirect_route: redirect_route,
            login_redirection_timeout: login_redirection_timeout)
end

ppv_yum_package login_comp_name do
  version pcas_comp_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{login_comp_name}/#{login_comp_name}.conf]", :immediately
  notifies :restart, "service[#{login_comp_name}]"
end

template "/opt/periscope/#{login_comp_name}/#{login_comp_name}.conf" do
  source 'pcas-app-config.erb'
  mode '0644'
  owner login_comp_name
  group login_comp_name
  variables(static_assets_root_dir: static_assets_root_dir,
            log_directory: log_directory,
            auth0_domain: auth0_domain,
            cz: cz,
            default_login_redirection_url: default_login_redirection_url,
            tableau_logout_url: tableau_logout_url,
            auth0_logout_url: auth0_logout_url,
            token_service_base_url: token_service_base_url,
            server_port: server_port,
            app_domain: app_domain,
            csrf_key: csrf_key)
  notifies :restart, "service[#{login_comp_name}]"
end

service login_comp_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end
