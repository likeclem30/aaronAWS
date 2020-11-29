databag_name = node['infra']['databag_name']
databag_item_name = node['infra']['databag_item']
infra_config = data_bag_item(databag_name, databag_item_name)

chef_environment = infra_config['chef_environment']

vpc_id = infra_config['vpc_id']

web_elb_security_group_name = infra_config['web_elb_security_group_name']
svc_elb_security_group_name = infra_config['svc_elb_security_group_name']
mgmt_elb_security_group_name = infra_config['mgmt_elb_security_group_name']
job_srv_elb_security_group_name = infra_config['job_srv_elb_security_group_name']
rdp_elb_security_group_name = infra_config['rdp_elb_security_group_name']

web_srv_security_group_name = infra_config['web_srv_security_group_name']
svc_srv_security_group_name = infra_config['svc_srv_security_group_name']
mgmt_srv_security_group_name = infra_config['mgmt_srv_security_group_name']
data_srv_security_group_name = infra_config['data_srv_security_group_name']

ipwl_sg_id = infra_config['ipwl_sg_id']
nat_sg_id = infra_config['nat_sg_id']
svc_int_elb = infra_config['svc_int_elb']
jobs_srv_security_group_name = infra_config['job_srv_security_group_name']
rdp_srv_security_group_name = infra_config['rdp_srv_security_group_name']

rdp_srv_count               = infra_config['rdp_srv_count'] || 0

svc_elb_ports = infra_config['svc_elb_ports']
db_port = infra_config['db_port']
shared_account_id = infra_config['shared_account_id']
rd_gw_sg = infra_config['rd_gw_sg_id'] ? { user_id: shared_account_id, group_id: infra_config['rd_gw_sg_id'] } : node['ipaddress']
provisioning_sg = infra_config['provisioning_sg_id'] ? { user_id: shared_account_id, group_id: infra_config['provisioning_sg_id'] } : node['ipaddress']

if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
elsif rdp_srv_count > 0
  whitelisted_ips = search('ppv-whitelisted-ips', 'ip:*').map { |ip| ip['ip'] }
end

aws_tags = {
  Environment: chef_environment,
  Solution: 'Periscope',
  Application: 'Periscope Suite',
  Billing: 'periscope-suite',
  Tenant: node['tenant_id'],
}

def get_inbound_rules(ports, sources)
  rules = []
  ports.each_with_index do |port_num, index|
    rule = { port: port_num, protocol: :tcp, sources: sources }
    rules.insert(index, rule)
  end
  rules
end

security_groups = []

# adding jobserver security group in the beginning to avoid cyclic dependency
unless jobs_srv_security_group_name.to_s.strip.empty?
  aws_security_group jobs_srv_security_group_name do
    vpc vpc_id
    aws_tags aws_tags
  end
end

security_groups.push(sg_name: web_elb_security_group_name,
                     sg_rules: [
                       { port: 80, protocol: :tcp, sources: [ipwl_sg_id] },
                     ],)

security_groups.push(sg_name: web_srv_security_group_name,
                     sg_rules: [
                       { port: 80, protocol: :tcp, sources: [web_elb_security_group_name] },
                       { port: 22, protocol: :tcp, sources: [nat_sg_id, provisioning_sg] },
                     ],)

security_groups.push(sg_name: mgmt_elb_security_group_name,
                     sg_rules: [
                       { port: 80, protocol: :tcp, sources: [ipwl_sg_id] },
                     ],)

security_groups.push(sg_name: mgmt_srv_security_group_name,
                     sg_rules: [
                       { port: 80, protocol: :tcp, sources: [mgmt_elb_security_group_name] },
                       { port: 22, protocol: :tcp, sources: [nat_sg_id, provisioning_sg] },
                     ],)

svc_srv_sources = [web_srv_security_group_name, mgmt_srv_security_group_name]
unless svc_elb_security_group_name.nil?
  svc_elb_sources = [web_srv_security_group_name, mgmt_srv_security_group_name]
  svc_elb_sources.push(jobs_srv_security_group_name) unless jobs_srv_security_group_name.nil?
  svc_elb_inbound_rules = get_inbound_rules(svc_elb_ports, svc_elb_sources)

  security_groups.push(sg_name: svc_elb_security_group_name,
                       sg_rules: svc_elb_inbound_rules,)

  svc_srv_sources = [svc_elb_security_group_name, mgmt_srv_security_group_name]
end

svc_inbound_rules = get_inbound_rules(svc_elb_ports, svc_srv_sources)
svc_inbound_rules = svc_inbound_rules.insert(svc_inbound_rules.length, port: 22, protocol: :tcp, sources: [nat_sg_id, provisioning_sg])
svc_inbound_rules = svc_inbound_rules.insert(svc_inbound_rules.length, port: 5985, protocol: :tcp, sources: [nat_sg_id, provisioning_sg])
svc_inbound_rules = svc_inbound_rules.insert(svc_inbound_rules.length, port: 5986, protocol: :tcp, sources: [nat_sg_id, provisioning_sg])

security_groups.push(sg_name: svc_srv_security_group_name,
                     sg_rules: svc_inbound_rules,)

db_sources = [web_srv_security_group_name, mgmt_srv_security_group_name, svc_srv_security_group_name]
db_sources.push(rdp_srv_security_group_name) if rdp_srv_count > 0
db_sources.push(jobs_srv_security_group_name) unless jobs_srv_security_group_name.nil?

security_groups.push(sg_name: data_srv_security_group_name,
                     sg_rules: [
                       { port: db_port, protocol: :tcp, sources: db_sources },
                       { port: 22, protocol: :tcp, sources: [nat_sg_id, provisioning_sg] },
                       { port: 5985, protocol: :tcp, sources: [nat_sg_id, provisioning_sg] },
                       { port: 5986, protocol: :tcp, sources: [nat_sg_id, provisioning_sg] },
                       { port: 3389, protocol: :tcp, sources: [nat_sg_id, rd_gw_sg] },
                     ],)

if rdp_srv_count > 0
  security_groups.unshift({
                            sg_name: rdp_elb_security_group_name,
                            sg_rules: [
                              { port: 3389, protocol: :tcp, sources: [whitelisted_ips] },
                            ],
                          },
                          sg_name: rdp_srv_security_group_name,
                          sg_rules: [
                            { port: 3389, protocol: :tcp, sources: [rdp_elb_security_group_name, provisioning_sg, rd_gw_sg] },
                            { port: 5985, protocol: :tcp, sources: [provisioning_sg] },
                            { port: 5986, protocol: :tcp, sources: [provisioning_sg] },
                          ])
end

job_srv_sources = [svc_srv_security_group_name, mgmt_srv_security_group_name]

unless job_srv_elb_security_group_name.nil?
  security_groups.push(sg_name: job_srv_elb_security_group_name,
                       sg_rules: [
                         { port: 8090, protocol: :tcp, sources: [svc_srv_security_group_name] },
                       ],)
  job_srv_sources = [job_srv_elb_security_group_name, mgmt_srv_security_group_name]
end

unless jobs_srv_security_group_name.nil?
  job_srv_inbound_rules = [{ port: 8090, protocol: :tcp, sources: job_srv_sources }]
  job_srv_inbound_rules.push(port: 22, protocol: :tcp, sources: [mgmt_srv_security_group_name, nat_sg_id, provisioning_sg])
  job_srv_inbound_rules.push(port: 80, protocol: :tcp, sources: [rdp_srv_security_group_name]) if rdp_srv_count > 0
  security_groups.push(sg_name: jobs_srv_security_group_name,
                       sg_rules: job_srv_inbound_rules,)
end

security_groups.each do |sg|
  aws_security_group sg[:sg_name] do
    vpc vpc_id
    aws_tags aws_tags
    inbound_rules sg[:sg_rules]
  end
end
