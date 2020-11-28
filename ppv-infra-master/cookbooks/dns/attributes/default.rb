default['dns']['databag_name'] = 'smoke_env'
default['dns']['databag_item'] = 'smoke'

case node['platform_family']
when 'windows'
  default['ipv4_command'] = 'powershell -c "invoke-restmethod -uri http://169.254.169.254/latest/meta-data/local-ipv4"'
when 'rhel'
  default['ipv4_command'] = 'curl http://169.254.169.254/latest/meta-data/local-ipv4'
end
