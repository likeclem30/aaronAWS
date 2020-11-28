databag_name = node['infra']['databag_name']
databag_item_name = node['infra']['databag_item']
db_secrets_databag_item_name = node['infra']['db_secrets']
infra_config = data_bag_item(databag_name, databag_item_name)
db_config = data_bag_item(databag_name, db_secrets_databag_item_name)

nexus_server_url = infra_config['nexus_server_url']

template '/etc/yum.repos.d/rpm-releases.repo' do
  source 'rpm_releases_repo.erb'
  variables(
    repo_name: node['infra']['repo_name'],
    repo_url: nexus_server_url,
    gpgcheck: node['infra']['gpgcheck'],
    is_enabled: node['infra']['is_enabled'],
    is_protected: node['infra']['is_protected'],
    metadata_expire: node['infra']['metadata_expire'],
    autorefresh: node['infra']['autorefresh'],
    type: node['infra']['type']
  )
  notifies :run, 'execute[yum_clean_all]', :immediately
end

execute 'yum_clean_all' do
  command 'yum clean all && yum repolist'
end

template '/etc/security/limits.conf' do
  source 'limits_conf.erb'
  variables(
    no_file: node['infra']['nofile']
  )
end

execute 'disable__selinux' do
  command 'setenforce 0'
  not_if 'sestatus | grep permissive'
end

package 'unzip'
package 'curl'

bash 'install aws cli' do
  code <<-EOH
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/tmp/awscli-bundle.zip"
    unzip /tmp/awscli-bundle.zip -d /tmp
    /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
  EOH
  not_if { ::File.exist?('/usr/local/bin/aws') }
end

node.set['fse_password'] = db_config['file_encryption_passphrase']
