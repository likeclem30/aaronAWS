sysctl_values = {

  'net.ipv4.conf.all.send_redirects' => 0,
  'net.ipv4.conf.default.send_redirects' => 0,
  'net.ipv4.tcp_max_syn_backlog' => 1280,
  'net.ipv4.icmp_echo_ignore_broadcasts' => 1,
  'net.ipv4.conf.all.accept_source_route' => 0,
  'net.ipv4.conf.all.accept_redirects' => 0,
  'net.ipv4.conf.all.secure_redirects' => 0,
  'net.ipv4.conf.all.log_martians' => 1,
  'net.ipv4.conf.default.accept_redirects' => 0,
  'net.ipv4.conf.default.secure_redirects' => 0,
  'net.ipv4.icmp_ignore_bogus_error_responses' => 1,
  'net.ipv4.tcp_syncookies' => 1,
  'net.ipv4.conf.all.rp_filter' => 1,
  'net.ipv4.tcp_timestamps' => 0,

}

template '/etc/sysctl.conf' do
  source 'sysctl.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(
    sysctl_values: sysctl_values
  )
end

sysctl_values.each do |k, v|
  execute "sysctl #{k}" do
    command "sysctl -w #{k}=#{v}"
    not_if "[[ $(sysctl -n #{k}) == \"#{v}\" ]]"
    notifies :run, 'execute[sysctl route flush]', :delayed
  end
end

execute 'sysctl route flush' do
  command 'sysctl -w net.ipv4.route.flush=1'
  action :nothing
end
