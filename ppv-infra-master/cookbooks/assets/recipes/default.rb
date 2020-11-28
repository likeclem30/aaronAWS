databag_name = node['assets']['databag_name']

component_name = node['assets']['component_name']

appversions_databag = data_bag_item(databag_name, 'appversions')

ppv_yum_package component_name do
  version appversions_databag['assets_version']
  flush_cache [:before]
end
