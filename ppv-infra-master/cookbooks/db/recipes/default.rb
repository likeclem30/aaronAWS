databag_name       = node['db']['databag_name']
appversions_config = data_bag_item(databag_name, node['db']['appversions_databag_name'])

db_helper_version = appversions_config['db_helper_version']

ppv_yum_package node['db']['helper']['package_name'] do
  version db_helper_version
  flush_cache [:before]
end
