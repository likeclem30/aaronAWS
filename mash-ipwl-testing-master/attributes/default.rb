#S3 or attribute
default['mash-ipwl-testing']['sites_config'] = 'attribute'
default['mash-ipwl-testing']['ips_config'] = 'attribute'
default['mash-ipwl-testing']['default_url'] = 'http://www.mckinseysolutions.com/'
default['mash-ipwl-testing']['secret_salt'] = 'AsHe8j98MZ@#$&^@#MijDTsJwf9879DP7'

default['mash-ipwl-testing']['large_client_header_buffers'] = '4 16k'
default['mash-ipwl-testing']['proxy_buffer_size'] = '256k'
default['mash-ipwl-testing']['proxy_buffers'] = '4 512k'
default['mash-ipwl-testing']['proxy_busy_buffers_size'] = '512k'

#IPWL configuration
default['mash-ipwl-testing']['default_nameserver'] = ''
default['mash-ipwl-testing']['nginx_dir'] = '/etc/nginx'
default['mash-ipwl-testing']['nginx_dir_temp'] = '/etc/nginx-ipwl-config-generated'
default['mash-ipwl-testing']['sites'] = {}
default['mash-ipwl-testing']['ip_whitelist'] = {}
default['mash-ipwl-testing']['trusted_proxies'] = {}

#IPWL configuration mode
default['mash-ipwl-testing']['mode_ipwl_bypass'] = false
default['mash-ipwl-testing']['mode_tableau'] = false
default['mash-ipwl-testing']['mode_true_client_ip_header'] = false

#S3 configuration
default['mash-ipwl-testing']['s3_region'] = 'us-east-1'
default['mash-ipwl-testing']['s3_sites'] = 's3://bucket/ipwl/sites_config'
default['mash-ipwl-testing']['ip_whitelist_config'] = 's3://bucket/ipwl/allowed_ips'
default['mash-ipwl-testing']['trusted_proxies_config'] = 's3://bucket/ipwl/trusted_proxies'

#ECR configuration
default['mash-ipwl-testing']['ecr_region'] = 'us-east-1'
default['mash-ipwl-testing']['ecr_registry_ids'] = '389017719203'
default['mash-ipwl-testing']['ecr_repo_uri'] = '389017719203.dkr.ecr.us-east-1.amazonaws.com/periscope/nginx-extras'

#Container test configuration
default['mash-ipwl-testing']['config_validation'] = true
default['mash-ipwl-testing']['container_name'] = 'nginx-ipwl'
default['mash-ipwl-testing']['sample_ips'] = {
  'x-forwarded-for_allow_test1' => '80.231.198.178',
  'x-forwarded-for_reject_test1' => '100.100.100.100',
  'x-forwarded-for_allow_test2' => '10.0.0.10, 80.231.198.178',
  'x-forwarded-for_reject_test2' => '80.231.198.178, 100.100.100.100'
}
