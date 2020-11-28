databag_name = node['it_admin']['databag_name']

component_name = node['it_admin']['assets']['component_name']

appversions_databag = data_bag_item(databag_name, 'appversions')

ppv_yum_package component_name do
  version appversions_databag['itracker_admin_assets_version']
  flush_cache [:before]
  notifies :create, 'template[/opt/periscope/itracker-admin-assets/public/config.js]', :immediately
end

template '/opt/periscope/itracker-admin-assets/public/config.js' do
  source 'itracker-admin-assets.conf.erb'
  mode '644'
end
