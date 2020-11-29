yum_package ['libxml2', 'libxml2-devel'] do
  action :install
  flush_cache [:before]
end.run_action :install

chef_gem 'chef-provisioning'
chef_gem 'chef-provisioning-aws'
chef_gem 'berkshelf'

execute 'aws configure' do
  command 'aws configure set default.region us-east-1'
  not_if { File.exist?("#{ENV['HOME']}/.aws/config") }
end
