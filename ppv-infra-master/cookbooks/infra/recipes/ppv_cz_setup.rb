include_recipe 'infra::default'
include_recipe 'infra::aws_security_group'

databag_name = node['infra']['databag_name']
databag_item_name = node['infra']['databag_item']
infra_config = data_bag_item(databag_name, databag_item_name)

win_image_id = infra_config['win_image_id']
instance_type = infra_config['instance_type']
device_name = infra_config['device_name']
web_subnet_ids	= infra_config['web_subnet_ids']
data_subnet_ids	= infra_config['data_subnet_ids']
service_subnet_ids	= infra_config['service_subnet_ids']
mgmt_subnet_ids	= infra_config['mgmt_subnet_ids']
public_subnet_ids = infra_config['public_subnet_ids']
databag_secret	= Chef::Config[:encrypted_data_bag_secret]
ppv_tenant_mgmt_srv_name = infra_config['ppv_tenant_mgmt_srv_name']
ppv_tenant_svc_srv_name 	= infra_config['ppv_tenant_svc_srv_name']
ppv_tenant_web_srv_name 	= infra_config['ppv_tenant_web_srv_name']
ppv_tenant_rdp_srv_name = infra_config['ppv_tenant_rdp_srv_name']
ppv_tenant_data_srv_name	= infra_config['ppv_tenant_data_srv_name']
ppv_tenant_mgmt_srv_runlist	= infra_config['machine_runlist']['ppv_tenant_mgmt_srv_runlist']
ppv_tenant_svc_srv_runlist     = infra_config['machine_runlist']['ppv_tenant_svc_srv_runlist']
ppv_tenant_svc_win_srv_runlist	= infra_config['machine_runlist']['ppv_tenant_svc_win_srv_runlist']
ppv_tenant_web_srv_runlist	= infra_config['machine_runlist']['ppv_tenant_web_srv_runlist']
ppv_tenant_data_srv_runlist	= infra_config['machine_runlist']['ppv_tenant_data_srv_runlist']
ppv_tenant_rdp_srv_runlist	= infra_config['machine_runlist']['ppv_tenant_rdp_srv_runlist']
chef_environment = infra_config['chef_environment']
web_iam_role                = infra_config['web_iam_role']
rdp_iam_role                = infra_config['rdp_iam_role']
mgmt_iam_role               = infra_config['mgmt_iam_role']
svc_iam_role                = infra_config['svc_iam_role']
data_iam_role               = infra_config['data_iam_role']
web_int_elb                 = infra_config['web_int_elb']
mgmt_int_elb                = infra_config['mgmt_int_elb']
svc_int_elb                 = infra_config['svc_int_elb']
rdp_ext_elb                 = infra_config['rdp_ext_elb']
web_elb_security_group_name = infra_config['web_elb_security_group_name']
mgmt_elb_security_group_name = infra_config['mgmt_elb_security_group_name']
svc_elb_security_group_name = infra_config['svc_elb_security_group_name']
rdp_elb_security_group_name = infra_config['rdp_elb_security_group_name']
web_srv_count               = infra_config['web_srv_count']
mgmt_srv_count              = infra_config['mgmt_srv_count']
svc_srv_count               = infra_config['svc_srv_count']
svc_win_srv_count           = infra_config['svc_win_srv_count']
db_srv_count                = infra_config['db_srv_count']
rdp_srv_count               = infra_config['rdp_srv_count'] || 0
data_instance_type          = infra_config['data_instance_type']
rdp_image_id                = infra_config['rdp_image_id']
rdp_instance_type           = infra_config['rdp_instance_type']
web_srv_security_group_name = infra_config['web_srv_security_group_name']
svc_srv_security_group_name = infra_config['svc_srv_security_group_name']
mgmt_srv_security_group_name = infra_config['mgmt_srv_security_group_name']
data_srv_security_group_name = infra_config['data_srv_security_group_name']
rdp_srv_security_group_name = infra_config['rdp_srv_security_group_name']
svc_elb_ports = infra_config['svc_elb_ports']
db_image_id = (infra_config['db_image_id'].nil? || infra_config['db_image_id'].empty?) ? infra_config['image_id'] : infra_config['db_image_id']
data_disk_letter = infra_config['data_disk_letter']
data_disk_mount_point = infra_config['data_disk_mount_point']
is_windows = infra_config['is_windows']

aws_tags = {
  Environment: chef_environment,
  Solution: 'Periscope',
  Application: 'Periscope Suite',
  Billing: 'periscope-suite',
  Tenant: node['tenant_id'],
}

use_elb = node['infra']['databag_name'] != 'smoke' && node['infra']['databag_name'] != 'qa'

unless infra_config['job_srv_security_group_name'].nil?
  include_recipe 'infra::emr_setup'
end

if is_windows == true
  1.upto(db_srv_count) do |i|
    machine "#{ppv_tenant_data_srv_name}#{i}-srv" do
      add_machine_options is_windows: true,
                          bootstrap_options: {
                            image_id: db_image_id,
                            block_device_mappings: [{
                              device_name: '/dev/sda1',
                              ebs: {
                                volume_size: 50,
                                volume_type: 'gp2',
                                delete_on_termination: true,
                              },
                            },
                                                    {
                                                      device_name: '/dev/xvdb',
                                                      ebs: {
                                                        volume_size: 80,
                                                        volume_type: 'gp2',
                                                        delete_on_termination: false,
                                                        encrypted: true,
                                                      },
                                                    },
                                                    {
                                                      device_name: '/dev/xvdc',
                                                      ebs: {
                                                        volume_size: 30,
                                                        volume_type: 'gp2',
                                                        delete_on_termination: false,
                                                        encrypted: true,
                                                      },
                                                    }],
                            instance_type: data_instance_type,
                            security_group_ids: [data_srv_security_group_name],
                            subnet_id:  data_subnet_ids[i % data_subnet_ids.length],
                            iam_instance_profile: {
                              name: data_iam_role,
                            },
                            monitoring: {
                              enabled: true,
                            },
                            disable_api_termination: true,
                          }
      files 'C:\\chef\\encrypted_data_bag_secret' => databag_secret
      chef_environment chef_environment
      run_list ppv_tenant_data_srv_runlist
    end
  end

else

  1.upto(db_srv_count) do |i|
    machine "#{ppv_tenant_data_srv_name}#{i}-srv" do
      add_machine_options bootstrap_options: {
        image_id: db_image_id,
        block_device_mappings: [{
          device_name: device_name,
          ebs: {
            volume_size: 15,
            volume_type: 'gp2',
            delete_on_termination: true,
          },
        },
                                {
                                  device_name: "/dev/sd#{data_disk_letter}",
                                  ebs: {
                                    volume_size: 60,
                                    volume_type: 'gp2',
                                    delete_on_termination: false,
                                    encrypted: true,
                                  },
                                }],
        instance_type: data_instance_type,
        security_group_ids: [data_srv_security_group_name],
        subnet_id:  data_subnet_ids[i % data_subnet_ids.length],
        iam_instance_profile: {
          name: data_iam_role,
        },
        monitoring: {
          enabled: true,
        },
        disable_api_termination: true,
      }
      files '/etc/chef/encrypted_data_bag_secret' => databag_secret
      chef_environment chef_environment
      run_list ppv_tenant_data_srv_runlist
      attributes ebs: {
        raids: {
          "/dev/xvd#{data_disk_letter}" => {
            disks: ["/dev/xvd#{data_disk_letter}"],
            fstype: 'ext4',
            mount_point: data_disk_mount_point,
          },
        },
      }
    end
  end
end

machine_batch do
  1.upto(svc_srv_count) do |i|
    machine "#{ppv_tenant_svc_srv_name}#{i}-srv" do
      add_machine_options bootstrap_options: {
        block_device_mappings: [{
          device_name: device_name,
          ebs: {
            volume_size: 30,
            volume_type: 'gp2',
            delete_on_termination: true,
          },
        }],
        instance_type: instance_type,
        security_group_ids: [svc_srv_security_group_name],
        subnet_id: service_subnet_ids[i % service_subnet_ids.length],
        iam_instance_profile: {
          name: svc_iam_role,
        },
        monitoring: {
          enabled: true,
        },
        disable_api_termination: true,
      }
      files '/etc/chef/encrypted_data_bag_secret' => databag_secret
      chef_environment chef_environment
      run_list ppv_tenant_svc_srv_runlist
    end
  end

  1.upto(svc_win_srv_count) do |i|
    machine "#{ppv_tenant_svc_srv_name}#{i + svc_srv_count}-srv" do
      add_machine_options is_windows: true,
                          bootstrap_options: {
                            image_id: win_image_id,
                            block_device_mappings: [{
                              device_name: device_name,
                              ebs: {
                                volume_size: 30,
                                delete_on_termination: true,
                                volume_type: 'gp2',
                              },
                            }],
                            instance_type: instance_type,
                            security_group_ids: ['rdp-access', svc_srv_security_group_name], # TODO: Phase out rdp-access after automated ppt service deployment
                            subnet_id: service_subnet_ids[1],
                            iam_instance_profile: {
                              name: svc_iam_role,
                            },
                          }
      # TODO: files '/etc/chef/encrypted_data_bag_secret' => databag_secret
      chef_environment chef_environment
      run_list ppv_tenant_svc_win_srv_runlist
    end
  end

  1.upto(web_srv_count) do |i|
    machine "#{ppv_tenant_web_srv_name}#{i}-srv" do
      add_machine_options bootstrap_options: {
        block_device_mappings: [{
          device_name: device_name,
          ebs: {
            volume_size: 30,
            volume_type: 'gp2',
            delete_on_termination: true,
          },
        }],
        instance_type: instance_type,
        security_group_ids: [web_srv_security_group_name],
        subnet_id: web_subnet_ids[i % web_subnet_ids.length],
        iam_instance_profile: {
          name: web_iam_role,
        },
        monitoring: {
          enabled: true,
        },
        disable_api_termination: true,
      }
      files '/etc/chef/encrypted_data_bag_secret' => databag_secret
      chef_environment chef_environment
      run_list ppv_tenant_web_srv_runlist
    end
  end

  1.upto(mgmt_srv_count) do |i|
    machine "#{ppv_tenant_mgmt_srv_name}#{i}-srv" do
      add_machine_options bootstrap_options: {
        block_device_mappings: [{
          device_name: device_name,
          ebs: {
            volume_size: 30,
            volume_type: 'gp2',
            delete_on_termination: true,
          },
        }],
        instance_type: instance_type,
        security_group_ids: [mgmt_srv_security_group_name],
        subnet_id:  mgmt_subnet_ids[i % mgmt_subnet_ids.length],
        iam_instance_profile: {
          name: mgmt_iam_role,
        },
        monitoring: {
          enabled: true,
        },
        disable_api_termination: true,
      }
      files '/etc/chef/encrypted_data_bag_secret' => databag_secret
      chef_environment chef_environment
      run_list ppv_tenant_mgmt_srv_runlist
    end
  end
end

svc_elb_listeners = []
0.upto(svc_elb_ports.length - 1) do |i|
  svc_elb_listeners.insert(i, port: svc_elb_ports[i],
                              protocol: :tcp,
                              instance_port: svc_elb_ports[i],
                              instance_protocol: :tcp)
end
load_balancer svc_int_elb do
  machines (1..svc_srv_count).map { |i| "#{ppv_tenant_svc_srv_name}#{i}-srv" }
  aws_tags aws_tags
  load_balancer_options subnets: service_subnet_ids,
                        security_groups: [svc_elb_security_group_name],
                        scheme: 'internal',
                        listeners: svc_elb_listeners,
                        health_check: {
                          healthy_threshold:    10,
                          unhealthy_threshold:  2,
                          interval:             30,
                          timeout:              5,
                          target:               "TCP:#{svc_elb_ports[0]}",
                        },
                        attributes: {
                          cross_zone_load_balancing: {
                            enabled: true,
                          },
                        }
  only_if { use_elb }
end

load_balancer web_int_elb do
  machines (1..web_srv_count).map { |i| "#{ppv_tenant_web_srv_name}#{i}-srv" }
  aws_tags aws_tags
  load_balancer_options subnets: web_subnet_ids,
                        security_groups: [web_elb_security_group_name],
                        scheme: 'internal',
                        listeners: [{
                          instance_port: 80,
                          protocol: 'HTTP',
                          instance_protocol: 'HTTP',
                          port: 80,
                        }],
                        health_check: {
                          healthy_threshold:    10,
                          unhealthy_threshold:  2,
                          interval:             30,
                          timeout:              5,
                          target:               'TCP:80',
                        },
                        attributes: {
                          cross_zone_load_balancing: {
                            enabled: true,
                          },
                        }
end

load_balancer mgmt_int_elb do
  machines (1..mgmt_srv_count).map { |i| "#{ppv_tenant_mgmt_srv_name}#{i}-srv" }
  aws_tags aws_tags
  load_balancer_options(
    subnets: mgmt_subnet_ids,
    security_groups: [mgmt_elb_security_group_name],
    scheme: 'internal',
    listeners: [{
      instance_port: 80,
      protocol: 'HTTP',
      instance_protocol: 'HTTP',
      port: 80,
    }],
    health_check: {
      healthy_threshold:    10,
      unhealthy_threshold:  2,
      interval:             30,
      timeout:              5,
      target:               'TCP:80',
    },
    attributes: {
      cross_zone_load_balancing: {
        enabled: true,
      },
    }
  )
end

(1..rdp_srv_count).each do |i|
  machine "#{ppv_tenant_rdp_srv_name}#{i}-srv" do
    add_machine_options is_windows: true,
                        bootstrap_options: {
                          block_device_mappings: [{
                            device_name: '/dev/sda1',
                            ebs: {
                              volume_size: 50,
                              volume_type: 'gp2',
                              delete_on_termination: true,
                            },
                          }],
                          image_id: rdp_image_id,
                          instance_type: rdp_instance_type,
                          security_group_ids: [rdp_srv_security_group_name],
                          subnet_id:  mgmt_subnet_ids[i % mgmt_subnet_ids.length],
                          iam_instance_profile: {
                            name: rdp_iam_role,
                          },
                          monitoring: {
                            enabled: true,
                          },
                          disable_api_termination: true,
                        }
    chef_environment chef_environment
    run_list ppv_tenant_rdp_srv_runlist
  end
end

load_balancer rdp_ext_elb do
  machines (1..rdp_srv_count).map { |i| "#{ppv_tenant_rdp_srv_name}#{i}-srv" }
  aws_tags aws_tags
  load_balancer_options(
    subnets: public_subnet_ids,
    security_groups: [rdp_elb_security_group_name],
    listeners: [{
      instance_port: 3389,
      protocol: 'TCP',
      instance_protocol: 'TCP',
      port: 3389,
    }],
    health_check: {
      healthy_threshold:    10,
      unhealthy_threshold:  2,
      interval:             30,
      timeout:              5,
      target:               'TCP:3389',
    }
  )
end if rdp_srv_count > 0

include_recipe 'dns::public_dns_entry' if use_elb
