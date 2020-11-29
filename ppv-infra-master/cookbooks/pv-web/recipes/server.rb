databag_name = node['pv-web']['databag_name']
pv_web_config = data_bag_item(databag_name, node['pv-web']['databag_item'])
appversions_config = data_bag_item(databag_name, node['pv-web']['appversions_databag_name'])

ppv_db_secrets = data_bag_item(databag_name, node['pv-web']['db_secrets'])
ppv_app_secrets = data_bag_item(databag_name, node['pv-web']['app_secrets'])

database_username           = ppv_db_secrets['ppv_app_user']
database_password           = ppv_db_secrets['ppv_app_password']

csrf_key                    = ppv_app_secrets['ppv_csrf_key']

app_id = pv_web_config['app_id']
database_server             = pv_web_config['database_server']
database_name               = pv_web_config['database_name']
tableau_public_url          = pv_web_config['tableau_public_url']
tableau_internal_url        = pv_web_config['tableau_internal_url']
tableau_site_name           = pv_web_config['tableau_site_name']
promotion_effectiveness_url = pv_web_config['promotion_effectiveness_url']
storyboard_service_url      = pv_web_config['storyboard_service_url']
storyboard_web_url          = pv_web_config['storyboard_web_url']
promotion_planning_url      = pv_web_config['promotion_planning_url']
ppt_service_url             = pv_web_config['ppt_service_url']
ppt_template_file_path      = pv_web_config['ppt_template_file_path']
use_auth0                   = pv_web_config['use_auth0']
token_service_url           = pv_web_config['token_service_url']
skip_ssl_verification       = pv_web_config['skip_ssl_verification']
homepage_service_url        = pv_web_config['homepage_service_url']
action_workflow_url         = pv_web_config['action_workflow_url']

pv_web_comp_version   = appversions_config['pv_web_comp_version']
pv_web_assets_version = appversions_config['pv_web_assets_version']

component_name = node['pv-web']['component_name']
log_directory  = "/opt/periscope/#{component_name}/logs"
log_level      = node['pv-web']['log_level']
is_tableau9    = node['pv-web']['is_tableau9']
app_port       = node['pv-web']['app_port']

ppv_yum_package node['pv-web']['assets_package_name'] do
  version pv_web_assets_version
  flush_cache [:before]
end

ppv_yum_package component_name do
  version pv_web_comp_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/#{component_name}.conf]", :immediately
  notifies :restart, "service[#{component_name}]"
end

template "/opt/periscope/#{component_name}/#{component_name}.conf" do
  source 'pv-web-app-config.erb'
  mode '0644'
  owner component_name
  group component_name
  variables(app_id: app_id,
            app_port: app_port,
            log_directory: log_directory,
            log_level: log_level,
            database_server: database_server,
            database_name: database_name,
            database_username: database_username,
            database_password: database_password,
            tableau_public_url: tableau_public_url,
            tableau_internal_url: tableau_internal_url,
            tableau_site_name: tableau_site_name,
            promotion_effectiveness_url: promotion_effectiveness_url,
            storyboard_service_url: storyboard_service_url,
            storyboard_web_url: storyboard_web_url,
            promotion_planning_url: promotion_planning_url,
            ppt_service_url: ppt_service_url,
            ppt_template_file_path: ppt_template_file_path,
            is_tableau9: is_tableau9,
            use_auth0: use_auth0,
            token_service_url: token_service_url,
            skip_ssl_verification: skip_ssl_verification,
            csrf_key: csrf_key,
            login_url: "#{node['base_app_url']}/auth/login?returnUrl=#{node['base_app_url']}/perf",
            logout_url: "#{node['base_app_url']}/auth/logout",
            heartbeat_url: "#{node['base_app_url']}/auth/heartbeat",
            homepage_service_url: homepage_service_url,
            action_workflow_url: action_workflow_url)
  notifies :restart, "service[#{component_name}]"
end

service component_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end
