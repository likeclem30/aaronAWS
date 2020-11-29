include_recipe 'database::postgresql'

# Set the Postgres password from the databag. So that this is same for both RDS and EC2.
db_secrets = data_bag_item(node['periscope']['databag_name'], node['periscope']['db_secrets_databag_item_name'])
node.default['postgresql']['password']['postgres'] = db_secrets['master_admin_password']

include_recipe 'pv-web::hba' if node['periscope']['tenant_modules'].include?('pv')
include_recipe 'sb-svc::hba' if node['periscope']['tenant_modules'].include?('sb')
include_recipe 'impact-tracker-server-cookbook::hba' if node['periscope']['tenant_modules'].include?('itracker')
include_recipe 'postgresql::server'
