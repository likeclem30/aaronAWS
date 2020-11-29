#
# Cookbook Name:: db
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'database::postgresql'

databag_name       = node['db']['databag_name']
db_config          = data_bag_item(databag_name, node['db']['it']['databag_item'])
app_database       = db_config['app_database']
login_user         = db_config['login_user']
schema_name        = db_config ['schema_name']

db_secrets = data_bag_item(databag_name, node['db']['secrets'])
admin_user     = db_secrets['it_admin_user']
admin_password = db_secrets['it_admin_password']
app_user       = db_secrets['it_app_user']
app_password   = db_secrets['it_app_password']

postgresql_connection_info = {
  host:     '127.0.0.1',
  port:     node['db']['config']['port'],
  username: login_user,
  password: node['postgresql']['password']['postgres'],
}

postgresql_admin_session_connection_info = {
  host:     '127.0.0.1',
  port:     node['db']['config']['port'],
  username: admin_user,
  password: admin_password,
  dbname:   app_database,
}

postgresql_database app_database do
  connection postgresql_connection_info
  action     :create
end

postgresql_database_schema schema_name do
  connection    postgresql_connection_info
  database_name app_database
  action        :create
end

# Create DB owner

postgresql_database_user admin_user do
  connection    postgresql_connection_info
  database_name app_database
  schema_name   schema_name
  password      admin_password
  login         true
  superuser     true
  action        [:create, :grant_db, :grant_schema]
end

# Create DB user

postgresql_database_user app_user do
  connection    postgresql_admin_session_connection_info
  database_name app_database
  login         true
  schema_name   schema_name
  password      app_password
  action        [:create, :grant_schema, :grant_sequences, :alter_roles]
end
