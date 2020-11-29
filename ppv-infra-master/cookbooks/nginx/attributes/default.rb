default['nginx']['arch'] = kernel['machine'] =~ /x86_64/ ? 'x86_64' : 'i686'
default['nginx']['version-release'] = ''
default['nginx']['repo_url'] = "http://nginx.org/packages/centos/#{node['platform_version'].to_i}/#{kernel['machine']}"
default['nginx']['gpgcheck'] = 0
default['nginx']['enabled'] = 1
default['nginx']['repo_name'] = 'nginx'
default['nginx']['user'] = 'nginx'
default['nginx']['group'] = 'nginx'
default['nginx']['databag_item'] = 'nginx'
default['nginx']['base_route'] = 'http://localhost:5005/home.html'
default['nginx']['pv-seed-svc']['databag_name'] = 'dev'
default['nginx']['pv-web']['databag_name'] = 'dev'
default['nginx']['pv-seed-svc']['databag_item'] = 'pvseedsvc'
default['nginx']['pv-web']['databag_item'] = 'pvweb'
default['nginx']['url_context'] = 'app_context'
default['nginx']['priceweb']['databag_name'] = 'dev'
default['nginx']['priceweb']['databag_item'] = 'nginx'
default['it']['databag_item'] = 'it'
default['infra']['databag_name'] = 'dev'
default['infra']['databag_item'] = 'env'
