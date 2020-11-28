require 'chef/provisioning/aws_driver'
# require 'chef/provisioning/ssh_driver'
# with_driver 'ssh'
iam = AWS::Core::CredentialProviders::ENVProvider.new 'AWS'

begin
  with_driver 'aws:IAM:us-east-1', aws_credentials: { 'IAM' => iam.credentials }
rescue AWS::Errors::MissingCredentialsError
  with_driver 'aws::us-east-1'
end

databag_name = node['infra']['databag_name']
infra_config = data_bag_item(databag_name, node['infra']['databag_item'])

image_id              = infra_config['image_id']
key_name              = infra_config['key_name']
ssh_user_name         = infra_config['ssh_user_name']
client_name           = infra_config['client_name'] || Chef::Config[:node_name]
signing_key_filename  = infra_config['signing_key_filename'] || Chef::Config[:client_key]
ssl_verify_mode       = infra_config['ssl_verify_mode']
chef_environment = infra_config['chef_environment']

with_chef_server node['infra']['chef_server_url'],
                 client_name: client_name,
                 signing_key_filename: signing_key_filename

with_machine_options(
  convergence_options: {
    ssl_verify_mode: ssl_verify_mode,
  },
  bootstrap_options:  {
    image_id: image_id,
    key_name: key_name,
  },
  aws_tags: {
    Environment: chef_environment,
    Solution: 'Periscope',
    Application: 'Periscope Suite',
    Billing: 'periscope-suite',
    Tenant: node['tenant_id'],
  },
  ssh_username: ssh_user_name,
  transport_address_location: :private_ip

)
