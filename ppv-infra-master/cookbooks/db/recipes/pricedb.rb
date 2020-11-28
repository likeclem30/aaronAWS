require 'mixlib/shellout'

chef_gem 'tiny_tds' do
  source node['infra']['gem_source']
  version '1.0.2'
end

require 'tiny_tds'

databag_name   = node['db']['databag_name']
db_config      = data_bag_item(databag_name, node['db']['price']['databag_item'])
db_secrets = data_bag_item(databag_name, node['db']['secrets'])

database_path = db_config['database_path']
database_log_path = db_config['database_log_path']

app_database = db_config['app_database']
admin_user     = db_secrets ['admin_user']
admin_password = db_secrets ['admin_password']
schema_names = db_config ['schema_names']
app_user       = db_secrets ['app_user']
app_password   = db_secrets ['app_password']

spark_user       = db_secrets ['spark_user']
spark_password   = db_secrets ['spark_password']

db_port = db_config['db_port']
sql_server_sysadmin_user = db_secrets['sysadmin_user']
sql_server_sysadmin_user_password = db_secrets['sysadmin_user_password']

sql_server_connection_info = {
  host:     '127.0.0.1',
  port:     db_port,
  username: sql_server_sysadmin_user,
  password: sql_server_sysadmin_user_password,
}

sql_server_database app_database do
  connection sql_server_connection_info
  database_path database_path
  database_log_path database_log_path
  action :create
end

schema_names.each do |schema_name|
  sql_server_database_schema schema_name do
    connection sql_server_connection_info
    database_name app_database
    action        :create
  end
end

# Create DB owner
sql_server_database_user admin_user do
  connection    sql_server_connection_info
  database_name app_database
  password      admin_password
  action        [:create, :grant]
end

sql_server_database_user app_user do
  connection    sql_server_connection_info
  database_name app_database
  password      app_password
  privileges    [:select, :update, :insert]
  action        [:create, :grant]
end

sql_server_database_user spark_user do
  connection    sql_server_connection_info
  database_name app_database
  password      spark_password
  privileges    [:select, :update, :insert]
  action        [:create]
end
