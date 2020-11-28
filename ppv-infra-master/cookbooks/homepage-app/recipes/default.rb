databag_name = node['homepage-app']['databag_name']
homepageapp_config = data_bag_item(databag_name, node['homepage-app']['databag_item'])
appversions_config = data_bag_item(databag_name, node['homepage-app']['appversions_databag_name'])

log_directory = homepageapp_config['log_directory']
server_port = homepageapp_config['server_port']
token_service_url = homepageapp_config['token_service_url']

main_menu_items = homepageapp_config['main_menu_items']
logout_item = homepageapp_config['logout_item']

homepage_app_svc_version = appversions_config['homepageapp_svc_version']

homepage_app_name = node['homepage-app']['component_name']

log_directory = "/opt/periscope/#{homepage_app_name}/logs"

ppv_yum_package homepage_app_name do
  version homepage_app_svc_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{homepage_app_name}/#{homepage_app_name}.conf]", :immediately
  notifies :restart, "service[#{homepage_app_name}]"
end

template "/opt/periscope/#{homepage_app_name}/#{homepage_app_name}.conf" do
  source 'homepage-app-config.erb'
  mode '0644'
  owner homepage_app_name
  group homepage_app_name
  variables(homepage_app_port: server_port,
            token_service_url: token_service_url,
            log_directory: log_directory,)
  notifies :restart, "service[#{homepage_app_name}]"
end

service homepage_app_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end

template "/opt/periscope/#{homepage_app_name}/sidebar.json" do
  source 'sidebar-json.erb'
  mode '0644'
  owner homepage_app_name
  group homepage_app_name
  variables(main_menu_items: main_menu_items.map(&:to_json),
            logout_title: logout_item['title'],
            logout_url: logout_item['url'])
end
