databag_name = node['db']['price']['databag_name']
db_config = data_bag_item(databag_name, node['db']['price']['databag_item'])
versions_config = data_bag_item(databag_name, node['db']['services']['databag_item'])
db_secrets = data_bag_item(databag_name, node['db']['secrets'])

configurationservice_migration_script = db_config['configurationservice_migration_script']
configurationservice_migrations_version = versions_config['configurationservice_migrations_version']
configurationservice_migrations_rpm_name = node['db']['configurationservice']['migrations_package_name']

db_server = db_config['db_server']
db_user_id = db_secrets['sysadmin_user']
db_password = db_secrets['sysadmin_user_password']
db_port = db_config['db_port']
db_name = db_config['db_name']

yum_package configurationservice_migrations_rpm_name do
  version configurationservice_migrations_version
  flush_cache [:before]
end

template "/opt/periscope/#{configurationservice_migrations_rpm_name}/public/dbconf.yml" do
  source 'dbconf.yml.erb'
  mode '644'
  variables(db_server: db_server,
            db_user_id: db_user_id,
            db_password: db_password,
            db_port: db_port,
            db_name: db_name)
  action :create
  notifies :run, 'bash[run_configurationservice_migrations]', :immediately
end

bash 'run_configurationservice_migrations' do
  code <<-EOH
    export DBDEPLOY_ENV='env'
    cd "/opt/periscope/#{configurationservice_migrations_rpm_name}/public"
    sh "./#{configurationservice_migration_script}"
    EOH
end
