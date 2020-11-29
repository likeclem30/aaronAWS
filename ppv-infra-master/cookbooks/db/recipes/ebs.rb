#
case node['platform']
when 'debian', 'ubuntu'
  package 'xfsprogs'
  package 'xfsdump'
  package 'xfslibs-dev'
when 'amazon', 'fedora'
  # xfsdump is not an Amazon Linux package at this moment.
  package 'xfsprogs'
  package 'xfsprogs-devel'
when 'redhat', 'centos'
  # RedHat 6 does not provide xfsprogs
end

package 'lvm2'

execute 'Load device mapper kernel module' do
  command 'modprobe dm-mod'
  ignore_failure true
end

node.set['ebs']['raids'].each do |raid_device, options|
  Chef::Log.info "Processing RAID #{raid_device} with options #{options} "
  lvm_device = BlockDevice.lvm_device(raid_device)

  Chef::Log.info("Waiting for individual disks of RAID #{options['mount_point']}")
  options['disks'].each do |disk_device|
    BlockDevice.wait_for(disk_device)
  end

  execute "mkfs_#{lvm_device}" do
    command "test \"$(blkid -s TYPE -o value #{lvm_device})\" = \"#{options['fstype']}\" || mkfs -t #{options['fstype']} #{lvm_device}"
    action :nothing
  end

  ruby_block "Create or attach LVM volume out of #{raid_device}" do
    block do
      BlockDevice.create_lvm(raid_device, options)
      BlockDevice.wait_for(lvm_device)
    end
    notifies :run, "execute[mkfs_#{lvm_device}]", :immediately
  end

  directory options['mount_point']

  mount options['mount_point'] do
    fstype options['fstype']
    device lvm_device
    options 'noatime'
    pass 0
    not_if do
      File.read('/etc/mtab').split("\n").any? do |line|
        line.match(" #{options['mount_point']} ")
      end
    end
  end

  mount "fstab entry for #{options['mount_point']}" do
    mount_point options['mount_point']
    action :enable
    fstype options['fstype']
    device lvm_device
    options 'noatime'
    pass 0
  end

  template 'rc.local script' do
    path value_for_platform(
      %w(centos redhat fedora amazon) => { 'default' => '/etc/rc.d/rc.local' },
      'default' => '/etc/rc.local'
    )
    source 'rc.local.erb'
    mode 0755
    owner 'root'
    group 'root'
  end
end
