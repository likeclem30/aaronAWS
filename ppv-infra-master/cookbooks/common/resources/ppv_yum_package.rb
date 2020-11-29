resource_name :ppv_yum_package

default_action :install

property :package_name, String, name_property: true
property :version, [String, Array]
property :flush_cache, [Hash, Array]

action :install do
  yum_package package_name do
    version new_resource.version unless new_resource.version == 'latest'
    flush_cache new_resource.flush_cache if new_resource.flush_cache
    action new_resource.version == 'latest' ? :upgrade : :install
  end
end
