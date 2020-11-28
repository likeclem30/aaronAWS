include_recipe 'route53'

databag_name = node['dns']['databag_name']
databag_item_name = node['dns']['databag_item']
dns_config = data_bag_item(databag_name, databag_item_name)

route53_internal_hosted_zone_name = dns_config['route53_internal_hosted_zone_name']
route53_internal_hosted_zone_id = dns_config['route53_internal_hosted_zone_id']

int_elb = dns_config['svc_int_elb']
int_elb_route53_name = dns_config['svc_route53_name']
ruby_block 'set attribute for srv svc' do
  block do
    cmd = Mixlib::ShellOut.new("aws elb describe-load-balancers \
                               --load-balancer-names #{int_elb} \
                               --output text --query \"LoadBalancerDescriptions[*].DNSName\"")
    cmd.run_command
    node.set['loadbalancer_name'] = cmd.stdout
  end
  lazy { notifies :create, 'ruby_block[update_route53_record_value_#{int_elb}]', :immediately }
end
ruby_block "update_route53_record_value_#{int_elb}" do
  block do
    route53 = resources("route53_record[create dns entry #{int_elb}]")
    route53.value = node['loadbalancer_name']
  end
end
route53_record "create dns entry #{int_elb}" do
  name "#{int_elb_route53_name}.#{route53_internal_hosted_zone_name}"
  value node['loadbalancer_name']
  type  'CNAME'
  zone_id route53_internal_hosted_zone_id.to_s
  aws_access_key_id ENV['AWS_ACCESS_KEY_ID']
  aws_secret_access_key ENV['AWS_SECRET_ACCESS_KEY']
  aws_session_token ENV['AWS_SESSION_TOKEN']
  overwrite true
  action :create
end
