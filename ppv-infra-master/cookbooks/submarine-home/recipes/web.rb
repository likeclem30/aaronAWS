databag_name = node['submarine']['databag_name']
component_name = node['submarine']['web']['component_name']

appversions_databag = data_bag_item(databag_name, 'appversions')

submarine_databag = data_bag_item(databag_name, 'submarine-home')

homepage_service_url = submarine_databag['homepage_service_url']
login_path = submarine_databag['login_path']
logout_path = submarine_databag['logout_path']
heartbeat_path = submarine_databag['heartbeat_path']

ppv_yum_package component_name do
  version appversions_databag['submarine_home_assets_version']
  flush_cache [:before]
end

template '/opt/periscope/submarine-home-assets/public/config.js' do
  source 'submarine-home-assets-config.js.erb'
  mode '644'
  variables(
    homepage_service_url: homepage_service_url,
    login_path: login_path,
    logout_path: logout_path,
    heartbeat_path: heartbeat_path,
  )
end
