databag_name = node['sb']['databag_name']
sb_web_config = data_bag_item(databag_name, node['sb']['web']['databag_item'])
appversions_config = data_bag_item(databag_name, node['sb']['appversions_databag_name'])
sb_app_secrets = data_bag_item(databag_name, node['sb']['app_secrets'])

csrf_key = sb_app_secrets['sb_web_csrf_key']

app_id = sb_web_config['app_id']
storyboard_service_url      = sb_web_config['storyboard_service_url']
promotion_effectiveness_url = sb_web_config['promotion_effectiveness_url']
promotion_planning_url      = sb_web_config['promotion_planning_url']
use_auth0                   = sb_web_config['use_auth0']
token_service_url           = sb_web_config['token_service_url']
homepage_service_url        = sb_web_config['homepage_service_url']
ppt_service_url             = sb_web_config['ppt_service_url']
ppt_template_file_path      = sb_web_config['ppt_template_file_path']

sb_web_comp_version = appversions_config['sb_web_comp_version']
sb_web_assets_version = appversions_config['sb_web_assets_version']

component_name = node['sb']['web']['component_name']
log_directory  = "/opt/periscope/#{component_name}/logs"
log_level      = node['sb']['log_level']
app_port       = node['sb']['web']['app_port']

ppv_yum_package node['sb']['web']['assets_package_name'] do
  version sb_web_assets_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{component_name}/#{component_name}.conf]", :immediately
  notifies :restart, "service[#{component_name}]"
end

ppv_yum_package component_name do
  version sb_web_comp_version
  flush_cache [:before]
  notifies :restart, "service[#{component_name}]"
end

template "/opt/periscope/#{component_name}/#{component_name}.conf" do
  source 'sb-web-app-config.erb'
  mode '0644'
  owner component_name
  group component_name
  variables(app_id: app_id,
            app_port: app_port,
            log_directory: log_directory,
            log_level: log_level,
            storyboard_service_url: storyboard_service_url,
            promotion_effectiveness_url: promotion_effectiveness_url,
            promotion_planning_url: promotion_planning_url,
            use_auth0: use_auth0,
            token_service_url: token_service_url,
            csrf_key: csrf_key,
            login_url: "#{node['base_app_url']}/auth/login?returnUrl=#{node['base_app_url']}/sb",
            logout_url: "#{node['base_app_url']}/auth/logout",
            heartbeat_url: "#{node['base_app_url']}/auth/heartbeat",
            homepage_service_url: homepage_service_url,
            ppt_service_url: ppt_service_url,
            ppt_template_file_path: ppt_template_file_path)
  notifies :restart, "service[#{component_name}]"
end

service component_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end
