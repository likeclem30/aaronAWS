#
# Cookbook Name:: price-etl
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
databag_name = node.environment
price_etl_config = data_bag_item(databag_name, node['price-etl']['databag_item'])
appversions_config = data_bag_item(databag_name, node['price-etl']['services']['databag_item'])
price_etl_app_secrets = data_bag_item(databag_name, node['app']['secrets'])
price_service_config = data_bag_item(databag_name, node['price-etl']['priceservice']['databag_item'])
db_secrets = data_bag_item(databag_name, node['db']['secrets'])
db_config = data_bag_item(databag_name, node['db']['databag_item'])

price_etl_comp_version = appversions_config['etl_version']
price_etl_assets_version = appversions_config['etl_frontend_version']
price_datamodel_etl_assets_version = appversions_config['datamodel_etl_assets_version']
query_service_url = price_service_config['query_endpoint']
fact_job_batch_size = price_etl_config['fact_job_batch_size']
token_service_url = price_service_config['tokenservice_endpoint']
login_url = price_etl_config['login_url']
csrf_key = price_etl_app_secrets['csrf_key']
logout_path = price_etl_config['logout_path']
heartbeat_path = price_etl_config['heartbeat_path']
configureusers_path = price_etl_config['configureusers_path']
price_path = price_etl_config['price_path']
server_prefix = price_etl_config['server_prefix']
price_etl_comp_name = node['price-etl']['comp_name']
app_port = node['price-etl']['app_port']
log_directory = "/opt/periscope/#{price_etl_comp_name}/logs"
database_username = db_secrets['app_user']
database_password = db_secrets['app_password']
database_name = db_config['db_name']
database_server = db_config['db_server']
database_port = db_config['db_port']
price_datamodel_etl_assets = node['price-datamodel-etl']['assets_package_name']
import_scripts_path = "/opt/periscope/#{price_datamodel_etl_assets}/public"

yum_package price_datamodel_etl_assets do
  version price_datamodel_etl_assets_version
  flush_cache [:before]
end

yum_package node['price-etl']['assets_package_name'] do
  version price_etl_assets_version
  flush_cache [:before]
end

template "/opt/periscope/#{price_etl_comp_name}/public/config.js" do
  source 'price-etl-assets-config.erb '
  mode '0644'
  owner price_etl_comp_name
  group price_etl_comp_name
  variables(
    logout_path: logout_path,
    server_prefix: server_prefix,
    heartbeat_path: heartbeat_path,
    configureusers_path: configureusers_path,
    price_path: price_path
  )
end

yum_package price_etl_comp_name do
  version price_etl_comp_version
  flush_cache [:before]
  notifies :create, "template[/opt/periscope/#{price_etl_comp_name}/#{price_etl_comp_name}.conf]", :immediately
  notifies :restart, "service[#{price_etl_comp_name}]"
end

template "/opt/periscope/#{price_etl_comp_name}/#{price_etl_comp_name}.conf" do
  source 'price-etl-app-config.erb'
  mode '0644'
  owner price_etl_comp_name
  group price_etl_comp_name
  variables(app_port: app_port,
            log_directory: log_directory,
            token_service_url: token_service_url,
            csrf_key: csrf_key,
            login_url: login_url,
            query_service_url: query_service_url,
            fact_job_batch_size: fact_job_batch_size,
            import_scripts_path: import_scripts_path,
            database_name: database_name,
            database_server: database_server,
            database_username: database_username,
            database_password: database_password,
            database_port: database_port)
  notifies :restart, "service[#{price_etl_comp_name}]"
end

service price_etl_comp_name do
  supports start: true, stop: true, restart: true, status: true, enable: true
  action [:enable, :restart]
end
