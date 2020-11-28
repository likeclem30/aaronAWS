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
db_config          = data_bag_item(databag_name, node['db']['sb']['databag_item'])
db_secrets = data_bag_item(databag_name, node['db']['secrets'])

app_database       = db_config['app_database']
schema_name        = db_config['schema_name']
login_user         = db_config['login_user']

app_user           = db_secrets['sb_app_user']
app_password       = db_secrets['sb_app_password']
admin_user         = db_secrets['sb_admin_user']
admin_password     = db_secrets['sb_admin_password']
backup_user        = db_secrets['sb_backup_user']
backup_password    = db_secrets['sb_backup_password']

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
  login         true
  password      admin_password
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
  action        [:create, :grant_schema, :alter_roles]
end

# Create Backup role
postgresql_database_user 'backup' do
  connection    postgresql_connection_info
  database_name app_database
  login         false
  superuser     true
  action        [:create, :grant_db]
end

# #Add user to backup role

postgresql_database_user backup_user do
  connection postgresql_connection_info
  rolename   'backup'
  password   backup_password
  action     [:create, :grant_role]
end

ruby_block 'remove-postgres-password' do
  block do
    node.rm('postgresql', 'password', 'postgres')
  end
end
