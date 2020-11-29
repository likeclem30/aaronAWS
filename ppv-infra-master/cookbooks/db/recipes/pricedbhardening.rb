databag_name = node['db']['price']['databag_name']
db_config = data_bag_item(databag_name, node['db']['price']['databag_item'])
db_secrets = data_bag_item(databag_name, node['db']['secrets'])

db_server = db_config['db_server']
db_user_id = db_secrets['sysadmin_user']
db_password = db_secrets['sysadmin_user_password']
db_port = db_config['db_port']
db_name = db_config['db_name']

spark_user_allowed_tables = db_config['spark_user_allowed_tables']
spark_user = db_secrets ['spark_user']
app_database = db_config['app_database']

directory '/opt/periscope/emr_hardening/public/migrations' do
  recursive true
  mode '0755'
end

template '/opt/periscope/emr_hardening/public/dbconf.yml' do
  source 'dbconf.yml.erb'
  mode '644'
  variables(db_server: db_server,
            db_user_id: db_user_id,
            db_password: db_password,
            db_port: db_port,
            db_name: db_name)
  action :create
end

template '/opt/periscope/emr_hardening/public/rundbdeploy.sh' do
  source 'rundbdeploy.sh.erb'
  mode '0755'
  action :create
end

template '/opt/periscope/emr_hardening/public/migrations/1_grant_permission.sql' do
  source '1_grant_permission.sql.erb'
  variables(db_tables: spark_user_allowed_tables,
            db_permissions: [:select, :update, :insert],
            db_username: spark_user,
            db_name: app_database)
end

bash 'grant permission to spark user' do
  code <<-EOH
    export DBDEPLOY_ENV='env'
    cd "/opt/periscope/emr_hardening/public"
    sh "./rundbdeploy.sh"
    EOH
  action :run
end
