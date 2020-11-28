databag_name = node['db']['price']['databag_name']
db_config = data_bag_item(databag_name, node['db']['price']['databag_item'])
versions_config = data_bag_item(databag_name, node['db']['services']['databag_item'])
db_secrets = data_bag_item(databag_name, node['db']['secrets'])

metadataservice_migration_script = db_config['metadataservice_migration_script']
metadataservice_migrations_version = versions_config['metadataservice_migrations_version']
metadataservice_migrations_rpm_name = node['db']['metadataservice']['migrations_package_name']

db_server = db_config['db_server']
db_user_id = db_secrets['sysadmin_user']
db_password = db_secrets['sysadmin_user_password']
db_port = db_config['db_port']
db_name = db_config['db_name']

yum_package metadataservice_migrations_rpm_name do
  version metadataservice_migrations_version
  flush_cache [:before]
end

template "/opt/periscope/#{metadataservice_migrations_rpm_name}/public/dbconf.yml" do
  source 'dbconf.yml.erb'
  mode '644'
  variables(db_server: db_server,
            db_user_id: db_user_id,
            db_password: db_password,
            db_port: db_port,
            db_name: db_name)
  action :create
  notifies :run, 'bash[run_metadataservice_migrations]', :immediately
end

bash 'run_metadataservice_migrations' do
  code <<-EOH
    export DBDEPLOY_ENV='env'
    cd "/opt/periscope/#{metadataservice_migrations_rpm_name}/public"
    sh "./#{metadataservice_migration_script}"
    EOH
end
