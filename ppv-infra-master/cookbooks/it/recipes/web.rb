databag_name = node['it']['databag_name']
component_name = node['it']['web']['component_name']

appversions_databag = data_bag_item(databag_name, 'appversions')

it_databag = data_bag_item(databag_name, 'it')

app_id = it_databag['app_id']
homepage_service_url = it_databag['homepage_service_url']

ppv_yum_package component_name do
  version appversions_databag['impact_tracker_web_version']
  flush_cache [:before]
  notifies :restart, 'service[nginx]'
end

template '/opt/periscope/impact-tracker-web/public/config.js' do
  source 'impact-tracker-web-config.conf.erb'
  mode '644'
  variables(
    app_id: app_id,
    homepage_service_url: homepage_service_url,
    logout_url: "#{node['base_app_url']}/auth/logout",
    heartbeat_url: "#{node['base_app_url']}/auth/heartbeat"
  )
end

service 'nginx' do
  supports start: true, stop: true, restart: true
end
