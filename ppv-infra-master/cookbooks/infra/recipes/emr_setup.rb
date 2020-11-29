include_recipe 'emr_cluster::create'

infra_databag_name = node['infra']['databag_name']
infra_databag_item_name = node['infra']['databag_item']
infra_config = data_bag_item(infra_databag_name, infra_databag_item_name)

spark_databag_name = node['spark']['databag_name']
spark_databag_item_name = node['spark']['databag_item']
spark_config = data_bag_item(spark_databag_name, spark_databag_item_name)

chef_environment = infra_config['chef_environment']
job_srv_int_elb             = infra_config['job_srv_int_elb']
job_srv_elb_subnets         = infra_config['job_srv_elb_subnets']
job_srv_elb_security_group_name = infra_config['job_srv_elb_security_group_name']
cluster_names = spark_config['spark_cluster_name']

aws_tags = {
  Environment: chef_environment,
  Solution: 'Periscope',
  Application: 'Periscope Suite',
  Billing: 'periscope-suite',
  Tenant: node['tenant_id'],
}

spark_master_machines = cluster_names.select { |cluster| "#{cluster}-master" }
load_balancer job_srv_int_elb do
  aws_tags aws_tags
  load_balancer_options subnets: job_srv_elb_subnets,
                        security_groups: [job_srv_elb_security_group_name],
                        scheme: 'internal',
                        listeners: [{
                          port: 8090,
                          protocol: :tcp,
                          instance_port: 8090,
                          instance_protocol: :tcp,
                        }],
                        health_check: {
                          healthy_threshold:    10,
                          unhealthy_threshold:  2,
                          interval:             30,
                          timeout:              5,
                          target:               'TCP:8090',
                        },
                        attributes: {
                          cross_zone_load_balancing: {
                            enabled: true,
                          },
                        }
  notifies :create, 'ruby_block[add_master_to_elb]', :immediately
end

ruby_block 'add_master_to_elb' do
  block do
    if node['infra']['databag_name'] != 'dev' && node['infra']['databag_name'] != 'qa'
      cluster_names.each do |cluster|
        add_master_to_elb(cluster, job_srv_int_elb)
      end
    end
  end
end

if node['infra']['databag_name'] != 'smoke' && node['infra']['databag_name'] != 'qa'
  include_recipe 'dns::emr_internal_elb_dns_entry'
end
