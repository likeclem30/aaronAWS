include_recipe 'route53'

databag_name = node['dns']['databag_name']
databag_item_name = node['dns']['databag_item']
dns_config = data_bag_item(databag_name, databag_item_name)

route53_internal_hosted_zone_name = dns_config['route53_internal_hosted_zone_name']
route53_internal_hosted_zone_id = dns_config['route53_internal_hosted_zone_id']
ipv4_cmd = node['ipv4_command']

cmd = Mixlib::ShellOut.new(ipv4_cmd)
cmd.run_command
ipv4_address = cmd.stdout

route53_record 'create dns entry' do
  name "#{node.name}.#{route53_internal_hosted_zone_name}"
  value ipv4_address
  type  'A'
  zone_id route53_internal_hosted_zone_id.to_s
  overwrite true
  action :create
end
