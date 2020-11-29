case node['platform']
when 'centos', 'redhat'
  default['security']['iptables_pkg'] = 'iptables-services'
when 'amazon'
  default['security']['iptables_pkg'] = 'iptables'
end

default['security']['iptables_ports'] = ['']
