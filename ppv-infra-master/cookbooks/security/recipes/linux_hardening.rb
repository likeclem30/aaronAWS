

bash 'enforce_password_policy' do
  code <<-EOH
  authconfig --passalgo=sha512 --update
  authconfig --passminlen=16 --update
  authconfig --passminclass=4 --update
  echo "Passwords expire every 180 days"
  sed -i 's/PASS_MAX_DAYS.*/PASS_MAX_DAYS 180/' /etc/login.defs
  echo "Passwords may only be changed once a day"
  sed -i 's/PASS_MIN_DAYS.*/PASS_MIN_DAYS 1/' /etc/login.defs
  EOH
end

bash 'securing_ssh' do
  code <<-EOH
  sed -i 's/#PermitRootLogin.*/PermitRootLogin No/' /etc/ssh/sshd_config
  sed -i 's/#Protocol.*/Protocol 2/' /etc/ssh/sshd_config
  EOH
  not_if 'grep -q "PermitRootLogin No" /etc/ssh/sshd_config && grep -q "Protocol 2" /etc/ssh/sshd_config'
  notifies :restart, 'service[sshd]'
end

service 'sshd' do
  action [:enable, :restart]
  supports start: true, stop: true, restart: true
end

include_recipe 'security::sysctl'

yum_package node['security']['iptables_pkg'] do
  action :install
  flush_cache [:before]
end

ports = node['security']['iptables_ports']

ports.each do |port|
  bash "add_iptables_rules_for_port_#{port}" do
    code <<-EOH
    iptables -A INPUT -p tcp --dport #{port} -j ACCEPT
    service iptables save
    EOH
    not_if "iptables --list -n | grep #{port}"
    notifies :restart, 'service[iptables]'
  end
end

service 'iptables' do
  action [:enable, :start]
  supports start: true, stop: true, restart: true
end

yum_package 'ntp' do
  action :install
  flush_cache [:before]
  notifies :restart, 'service[ntpd]'
end

service 'ntpd' do
  action [:enable, :start]
  supports start: true, stop: true, restart: true
end

yum_package 'audit' do
  action :install
  flush_cache [:before]
end

file '/var/log/audit/audit.log' do
  mode '0640'
end

template '/etc/audit/audit.rules' do
  source 'audit.rules.erb'
  owner 'root'
  group 'root'
  mode 0644
end

service 'auditd' do
  action [:enable, :start]
  restart_command 'service auditd restart'
  supports start: true, stop: true, restart: true
end

include_recipe 'security::selinux'
