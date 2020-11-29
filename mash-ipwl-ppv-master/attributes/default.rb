#S3 or attribute
default['mash-ipwl-ppv']['sites_config'] = 'attribute'
default['mash-ipwl-ppv']['ips_config'] = 'attribute'
default['mash-ipwl-ppv']['default_url'] = 'http://www.mckinseysolutions.com/'
default['mash-ipwl-ppv']['secret_salt'] = 'AsHe8j98MZ@#$&^@#MijDTsJwf9879DP7'

default['mash-ipwl-ppv']['large_client_header_buffers'] = '4 16k'
default['mash-ipwl-ppv']['proxy_buffer_size'] = '256k'
default['mash-ipwl-ppv']['proxy_buffers'] = '4 512k'
default['mash-ipwl-ppv']['proxy_busy_buffers_size'] = '512k'

#IPWL configuration
default['mash-ipwl-ppv']['default_nameserver'] = ''
default['mash-ipwl-ppv']['nginx_dir'] = '/etc/nginx'
default['mash-ipwl-ppv']['nginx_dir_temp'] = '/etc/nginx-ipwl-config-generated'
default['mash-ipwl-ppv']['sites'] = {}
default['mash-ipwl-ppv']['ip_whitelist'] = {}
default['mash-ipwl-ppv']['trusted_proxies'] = {}

#IPWL configuration mode
default['mash-ipwl-ppv']['mode_ipwl_bypass'] = false
default['mash-ipwl-ppv']['mode_tableau'] = false
default['mash-ipwl-ppv']['mode_true_client_ip_header'] = false

#S3 configuration
default['mash-ipwl-ppv']['s3_region'] = 'us-east-1'
default['mash-ipwl-ppv']['s3_sites'] = 's3://bucket/ipwl/sites_config'
default['mash-ipwl-ppv']['ip_whitelist_config'] = 's3://bucket/ipwl/allowed_ips'
default['mash-ipwl-ppv']['trusted_proxies_config'] = 's3://bucket/ipwl/trusted_proxies'

#ECR configuration
default['mash-ipwl-ppv']['ecr_region'] = 'us-east-1'
default['mash-ipwl-ppv']['ecr_registry_ids'] = '389017719203'
default['mash-ipwl-ppv']['ecr_repo_uri'] = '389017719203.dkr.ecr.us-east-1.amazonaws.com/periscope/nginx-extras'

#Container test configuration
default['mash-ipwl-ppv']['config_validation'] = true
default['mash-ipwl-ppv']['container_name'] = 'nginx-ipwl'
default['mash-ipwl-ppv']['sample_ips'] = {
  'x-forwarded-for_allow_test1' => '80.231.198.178',
  'x-forwarded-for_reject_test1' => '100.100.100.100',
  'x-forwarded-for_allow_test2' => '10.0.0.10, 80.231.198.178',
  'x-forwarded-for_reject_test2' => '80.231.198.178, 100.100.100.100'
}
