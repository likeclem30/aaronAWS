databag_name   = node['db']['databag_name']
db_config      = data_bag_item(databag_name, node['db']['pv']['migration']['databag_item'])
db_secrets = data_bag_item(databag_name, node['db']['secrets'])
appversions_config = data_bag_item(databag_name, node['db']['appversions_databag_name'])

host = db_config['host']
db_name        = db_config['db_name']
schema_name    = db_config['schema_name']
sslmode        = db_config['sslmode']
script_path    = db_config['script_path']

user = db_secrets['ppv_admin_user']
password = db_secrets['ppv_admin_password']

pv_migrations_version = appversions_config['pv_migrations_version']

data_source = "host=#{host} user=#{user} password=#{password} dbname=#{db_name} search_path=#{schema_name} sslmode=#{sslmode}"

ppv_yum_package node['db']['pv']['migrations_package_name'] do
  version pv_migrations_version
  flush_cache [:before]
  notifies :run, 'bash[run_pv_migrations]', :immediately
end

bash 'run_pv_migrations' do
  code <<-EOH
    cd /opt/periscope/db-helper
    ./db_helper-linux -datasource="#{data_source}" -scriptpath="#{script_path}" upgrade;
    EOH
end
