databag_name   = node['db']['databag_name']
db_config      = data_bag_item(databag_name, node['db']['price']['databag_item'])
db_secrets = data_bag_item(databag_name, node['db']['secrets'])

data_directory = db_config['database_path']
log_directory = db_config['database_log_path']
backup_directory = db_config['database_backup_path']
db_port = db_config['db_port']
sql_server_sysadmin_user = db_secrets['sysadmin_user']
sql_server_sysadmin_user_password = db_secrets['sysadmin_user_password']
enable_agent_script = node['sql_server']['enable_agent_script_path']
initialize_management_db_script = node['sql_server']['initialize_management_db_script_path']
management_db_name = node['sql_server']['management_db_name']
database_backup_scripts_dir = db_config['database_backup_scripts_dir']
reg_version = case node['sql_server']['version']
              when '2008' then 'MSSQL10.'
              when '2008R2' then 'MSSQL10_50.'
              when '2012' then 'MSSQL11.'
              when '2014' then 'MSSQL12.'
              when '2016' then 'MSSQL13.'
              else raise "Unsupported sql_server version '#{node['sql_server']['version']}'"
              end

sql_server_agent_service_name = node['sql_server']['agent_service']
service_name = node['sql_server']['instance_name']

directory data_directory.to_s do
  action :create
  recursive true
end

directory log_directory.to_s do
  action :create
  recursive true
end

directory backup_directory.to_s do
  rights :modify, 'NT Service\SQLSERVERAGENT'
  action :create
  recursive true
end

registry_key "HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Microsoft SQL Server\\#{reg_version}MSSQLServer\\#{service_name}" do
  values [{
    name: 'LoginMode',
    type: :dword,
    data: '2',
  },]
end

cookbook_file enable_agent_script.to_s do
  source 'sqlserver_enable_agent_xps.sql'
end

cookbook_file initialize_management_db_script.to_s do
  source 'sqlserver_initialize_management_db.sql'
end

powershell_script 'Create Management Database' do
  guard_interpreter :powershell_script
  code <<-EOH
  SQLCMD -i `"#{enable_agent_script}`" -b
 EOH
end

powershell_script 'Create_SQL_Sysadmin_user' do
  guard_interpreter :powershell_script
  code <<-EOH
    SQLCMD -Q "CREATE LOGIN [#{sql_server_sysadmin_user}] WITH PASSWORD=N'#{sql_server_sysadmin_user_password}', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON;"
    SQLCMD -Q "ALTER SERVER ROLE [sysadmin] ADD MEMBER [#{sql_server_sysadmin_user}];"
    net stop  #{service_name} /yes
    net start #{service_name}
    net start #{sql_server_agent_service_name}
    EOH
end

powershell_script 'Create Management Database' do
  guard_interpreter :powershell_script
  code <<-EOH
   SQLCMD -v management_database=`"#{management_db_name}`" data_dir=`"#{data_directory}`" log_dir=`"#{log_directory}`" backup_dir=`"#{backup_directory}`" remote_save_command=`"#{database_backup_scripts_dir}\\copy_backup.ps1`" backup_user=`"#{sql_server_sysadmin_user}`" -b -I -i `"#{initialize_management_db_script}`"
 EOH
end

firewall_rule_name = "#{db_port} Static Port"
execute 'open-static-port' do
  command "netsh advfirewall firewall add rule name=\"#{firewall_rule_name}\" dir=in action=allow protocol=TCP localport=#{db_port}"
  returns [0, 1, 42]
  not_if "netsh advfirewall firewall show rule name=\"#{firewall_rule_name}\""
end
