management_db_name = node['sql_server']['management_db_name']
databag_name   = node['db']['databag_name']
db_config      = data_bag_item(databag_name, node['db']['price']['databag_item'])
app_database = db_config['app_database']
database_backup_scripts_dir = db_config['database_backup_scripts_dir']
s3_database_backup_path = db_config['s3_database_backup_path']

directory database_backup_scripts_dir.to_s do
  action :create
  recursive true
end

template "#{database_backup_scripts_dir}\\copy_backup.ps1" do
  source 'copy_backup.ps1.erb'
  variables target_location: s3_database_backup_path
  action :create
end

powershell_script 'Create backup' do
  guard_interpreter :powershell_script
  code <<-EOH
    SQLCMD -Q "EXEC [#{management_db_name}].[dbo].[CreateDatabaseMaintenancePlan] '#{app_database}'"
    EOH
end
