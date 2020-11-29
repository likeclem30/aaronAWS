default['db']['config']['port'] = '5432'
default['db']['sb']['databag_item'] = 'sbdb'
default['db']['pv']['databag_item'] = 'pvdb'
default['db']['it']['databag_item'] = 'itdb'
default['db']['price']['databag_item'] = 'db'
default['db']['sb']['migration']['databag_item'] = 'sbdbmigration'
default['db']['pv']['migration']['databag_item'] = 'pvdbmigration'
default['db']['it']['migration']['databag_item'] = 'itdbmigration'
default['db']['pv']['migrations_package_name'] = 'perf-web-migrations'
default['db']['sb']['migrations_package_name'] = 'sb-svc-migrations'
default['db']['it']['migrations_package_name'] = 'impact-tracker-server-migrations'
default['db']['calcenginedataservice']['migrations_package_name'] = 'calcenginedataservice-migrations'
default['db']['price_etl']['migrations_package_name'] = 'price-etl-migrations'
default['db']['competitorservice']['migrations_package_name'] = 'competitorservice-migrations'
default['db']['configurationservice']['migrations_package_name'] = 'configurationservice-migrations'
default['db']['metadataservice']['migrations_package_name'] = 'metadataservice-migrations'
default['db']['queryservice']['migrations_package_name'] = 'queryservice-migrations'
default['db']['sb']['migrations_version'] = '1.2.39-1'
default['db']['pv']['migrations_version'] = '1.2.56-1'
default['db']['it']['migrations_version'] = '1.0.54-1'
default['db']['helper']['package_name'] = 'db-helper'
default['db']['helper']['version'] = '1.2.105-1'
default['db']['appversions_databag_name'] = 'appversions'
default['db']['databag_name'] = 'smoke'
default['db']['secrets'] = 'db-secrets'
default['db']['price']['databag_name'] = 'dev'
default['db']['services']['databag_item'] = 'appversions'
default['sql_server']['instance_name'] = 'MSSQLSERVER'
default['sql_server']['agent_service'] = 'SQLSERVERAGENT'
default['sql_server']['version'] = '2012'
default['sql_server']['enable_agent_script_path'] = 'D:\\SQLData\\sqlserver_enable_agent_xps.sql'
default['sql_server']['initialize_management_db_script_path'] = 'D:\\SQLData\\sqlserver_initialize_management_db.sql'
default['sql_server']['management_db_name'] = 'PeriscopeDBManagement'
default_unless['ebs']['devices'] = {}
default_unless['ebs']['raids'] = {}
default['ebs']['mdadm_chunk_size'] = '256'
default['ebs']['md_read_ahead'] = '65536' # 64k
default['sql_server']['target_location'] = 'D:\\SQLData\\remote'
default['infra']['gem_source'] = 'https://nexus-npn.mckinsey-solutions.com/nexus/content/repositories/rubygems-org/'

if BlockDevice.on_kvm?
  Chef::Log.info('Running on QEMU/KVM: Need to translate device names as KVM allocates them regardless of the given device ID')
  ebs_devices = {}

  new_device_names = BlockDevice.translate_device_names(ebs['devices'].keys)
  new_device_names.each do |names|
    new_name = names[1]
    old_name = names[0]
    ebs_devices[new_name] = ebs['devices'][old_name]
  end
  set['ebs']['devices'] = ebs_devices

  skip_chars = new_device_names.size
  ebs['raid'].each do |raid_device, config|
    new_raid_devices = BlockDevice.translate_device_names(config['disks'], skip_chars).map { |names| names[1] }
    set['ebs']['raids'][raid_device]['disks'] = new_raid_devices
    skip_chars = new_raid_devices.size
  end
end
