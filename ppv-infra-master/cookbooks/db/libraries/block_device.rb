# Module BlockDevice
# rubocop:disable ModuleLength
module BlockDevice
  def self.wait_for(device)
    loop do
      if File.blockdev?(device)
        Chef::Log.info("device #{device} ready")
        break
      else
        Chef::Log.info("device #{device} not ready - waiting")
        sleep 10
      end
    end
  end

  def self.wait_for_logical_volumes
    loop do
      lvscan = exec_command_output('lvscan')
      if lvscan.lines.all? { |line| line.include?('ACTIVE') }
        Chef::Log.debug("All LVM volume disks seem to be active:\n#{lvscan}")
        break
      else
        Chef::Log.debug("Not all LVM volume disks seem to be active, waiting 10 more seconds:\n#{lvscan}")
        sleep 10
        vgchange_status = exec_command_output('vgchange -ay')
        Chef::Log.debug("Tried to activate all local volume groups:\n#{vgchange_status}")
      end
    end
  end

  def self.existing_raid_at?(device)
    raids = exec_command_output('mdadm --examine --scan')

    if raids.match(device) || raids.match(device.gsub(/md/, 'md/'))
      Chef::Log.debug("Checking for existing RAID arrays at #{device}: #{raids}")
      Chef::Log.info("Checking for existing RAID arrays at #{device}: true")
      true
    else
      Chef::Log.debug("Checking for existing RAID arrays at #{device}: #{raids}")
      Chef::Log.info("Checking for existing RAID arrays at #{device}: false")
      false
    end
  end

  def self.assembled_raid_at?(device)
    raids = exec_command_output('mdadm --detail --scan')

    if raids.match(device)
      Chef::Log.debug("Checking for running RAID arrays at #{device}: #{raids}")
      Chef::Log.info("Checking for running RAID arrays at #{device}: true")
      clean_raid_at?(device)
    else
      Chef::Log.debug("Checking for running RAID arrays at #{device}: #{raids}")
      Chef::Log.info("Checking for running RAID arrays at #{device}: false")
      false
    end
  end

  def self.clean_raid_at?(raid_device)
    OpsWorks::ShellOut.shellout("mdadm --detail --test #{raid_device} > /dev/null")
    Chef::Log.info("RAID array at #{raid_device} is clean")
    true
  rescue
    Chef::Log.info("RAID array at #{raid_device} is not clean")
    false
  end

  # rubocop:disable PerceivedComplexity
  def self.assemble_raid(raid_device, options)
    info_msg = "Resuming existing RAID array #{raid_device} with #{options[:disks].size} disks, "\
      "RAID level #{options[:raid_level]} at #{options[:mount_point]}"
    Chef::Log.info info_msg
    unless exec_command("mdadm --assemble --verbose #{raid_device} #{options[:disks].join(' ')}")
      plain_disks = options[:disks].map { |disk| disk.gsub('/dev/', '') }
      affected_volume_groups = []
      File.readlines('/proc/mdstat').each do |line|
        md_device = nil
        md_device = line.split.first if plain_disks.any? { |disk| line.include?(disk) }
        next unless md_device
        physical_volume_info = exec_command_output('pvdisplay -c /dev/#{md_device}').lines.first
        if physical_volume_info
          volume_group = begin
                             physical_volume_info.split(':')[1]
                           rescue
                             nil
                           end
          if volume_group
            affected_volume_groups << volume_group
            Chef::Log.info "Deactivating volume group #{volume_group}"
            exec_command("vgchange --available n #{volume_group}")
          end
        end
        Chef::Log.info "Stopping /dev/#{md_device}"
        exec_command("mdadm --stop --verbose /dev/#{md_device}")
      end
      exec_command("mdadm --assemble --verbose #{raid_device} #{options[:disks].join(' ')}") || raise("Failed to assemble the RAID array at #{raid_device}")
      affected_volume_groups.each do |volume_group|
        Chef::Log.info "(Re-)activating volume group #{volume_group}"
        exec_command("vgchange --available y #{volume_group}")
      end
    end
  end

  def self.create_raid(raid_device, options)
    Chef::Log.info "creating RAID array #{raid_device} with #{options[:disks].size} disks, RAID level #{options[:raid_level]} at #{options[:mount_point]}"
    command = "yes n | mdadm --create --chunk=#{options[:chunk_size]} --metadata=1.2 --verbose #{raid_device} "\
      "--level=#{options[:raid_level]} --raid-devices=#{options[:disks].size} #{options[:disks].join(' ')}"
    exec_command(command) || raise("Failed to create the RAID array at #{raid_device}")
  end

  def self.set_read_ahead(raid_device, ahead_option)
    Chef::Log.info "Setting read ahead options for RAID array #{raid_device} to #{ahead_option}"
    exception_message = "Failed to set read ahead options for RAID array at #{raid_device} to #{ahead_option}"
    exec_command("blockdev --setra #{ahead_option} #{raid_device}") || raise(exception_message)
  end

  def self.lvm_device(raid_device)
    "/dev/#{lvm_volume_group(raid_device)}/lvm#{raid_device[-1]}"
  end

  def self.lvm_volume_group(raid_device)
    "lvm-raid-#{raid_device[-1]}"
  end

  def self.existing_lvm_at?(lvm_device)
    lvms = exec_command_output('lvscan')
    if lvms.match(lvm_device)
      Chef::Log.debug("Checking for active LVM volumes at #{lvm_device}: #{lvms}")
      Chef::Log.debug("Checking for active LVM volumes at #{lvm_device}: true")
      true
    else
      Chef::Log.debug("Checking for active LVM volumes at #{lvm_device}: #{lvms}")
      Chef::Log.debug("Checking for active LVM volumes at #{lvm_device}: false")
      false
    end
  end

  def self.create_lvm(raid_device, options)
    Chef::Log.info "creating LVM volume out of #{raid_device} with #{options[:disks].size} disks at #{options[:mount_point]}"
    unless lvm_physical_group_exists?(raid_device)
      exec_command("pvcreate #{raid_device}") || raise("Failed to create LVM physical disk for #{raid_device}")
    end
    unless lvm_volume_group_exists?(raid_device)
      exec_command("vgcreate #{lvm_volume_group(raid_device)} #{raid_device}") || raise("Failed to create LVM volume group for #{raid_device}")
    end
    unless lvm_volume_exits?(raid_device)
      lvc_create_command = "lvcreate -l 100%FREE #{lvm_volume_group(raid_device)} -n #{File.basename(lvm_device(raid_device))}"
      exec_command(lvc_create_command) || raise("Failed to create the LVM volume at #{raid_device}")
    end
  end

  def self.lvm_physical_group_exists?(raid_device)
    pvscan = exec_command_output('pvscan')
    if pvscan.match(raid_device)
      Chef::Log.debug("Checking for existing LVM physical disk for #{raid_device}: #{pvscan}")
      Chef::Log.debug("Checking for existing LVM physical disk for #{raid_device}: true")
      true
    else
      Chef::Log.debug("Checking for existing LVM physical disk for #{raid_device}: #{pvscan}")
      Chef::Log.debug("Checking for existing LVM physical disk for #{raid_device}: false")
      false
    end
  end

  def self.lvm_volume_group_exists?(raid_device)
    vgscan = exec_command_output('vgscan')
    if vgscan.match(lvm_volume_group(raid_device))
      Chef::Log.debug("Checking for existing LVM volume group for #{lvm_volume_group(raid_device)}: #{vgscan}")
      Chef::Log.debug("Checking for existing LVM volume group for #{lvm_volume_group(raid_device)}: true")
      true
    else
      Chef::Log.debug("Checking for existing LVM volume group for #{lvm_volume_group(raid_device)}: #{vgscan}")
      Chef::Log.debug("Checking for existing LVM volume group for #{lvm_volume_group(raid_device)}: false")
      false
    end
  end

  def self.lvm_volume_exits?(raid_device)
    wait_for_logical_volumes
    lvscan = exec_command_output('lvscan')
    if lvscan.match(lvm_device(raid_device))
      Chef::Log.debug("Checking for existing LVM volume disk for #{lvm_device(raid_device)}: #{lvscan}")
      Chef::Log.debug("Checking for existing LVM volume disk for #{lvm_device(raid_device)}: true")
      true
    else
      Chef::Log.debug("Checking for existing LVM volume disk for #{lvm_device(raid_device)}: #{lvscan}")
      Chef::Log.debug("Checking for existing LVM volume disk for #{lvm_device(raid_device)}: false")
      false
    end
  end

  def self.exec_command(command)
    Chef::Log.debug("Executing: #{command}")
    cmd = Mixlib::ShellOut.new(command)
    cmd.run_command
    output = cmd.stdout
    if cmd.error?
      Chef::Log.fatal output
      false
    else
      Chef::Log.info output
      true
    end
  end

  def self.translate_device_names(devices, skip = 0)
    if on_kvm? && !devices.empty?
      Chef::Log.info("Running on QEMU/KVM: Starting at /dev/sdb skipping #{skip}")
      new_devices = ('b'..'z').to_a[0 + skip, devices.size].each_with_index.map { |char, index| [devices[index], "/dev/sd#{char}"] }
      Chef::Log.info("Running on QEMU/KVM: Translated EBS devices #{devices.inspect} to #{new_devices.map { |d| d[1] }.inspect}")
      new_devices
    else
      devices
    end
  end

  def self.on_kvm?
    cmd = Mixlib::ShellOut.new('cat /proc/cpuinfo')
    cmd.run_command
    cmd.stdout.match(/QEMU/)
  end

  def self.exec_command_output(cmd)
    Chef::Log.debug("Executing: #{cmd}")
    cmd = Mixlib::ShellOut.new(cmd)
    cmd.run_command
    raise cmd.stderr if cmd.error?
    Chef::Log.info cmd.stdout
    cmd.stdout
  end
end
