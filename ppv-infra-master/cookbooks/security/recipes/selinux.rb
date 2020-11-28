case node['platform']
when 'amazon'
  yum_package ['selinux-policy', 'selinux-policy-targeted', 'policycoreutils-python'] do
    action :install
  end

  bash 'enable_selinux_permissive' do
    code <<-EOH
    sed -i 's/SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
    sed -i 's/SELINUXTYPE=.*/SELINUXTYPE=targeted/' /etc/selinux/config
    sed -i 's/KEYTABLE=us/KEYTABLE=us selinux=1 security=selinux/' /boot/grub/menu.lst
      EOH
    not_if '(sestatus | grep permissive) && (grep -q "selinux=1 security=selinux" /boot/grub/menu.lst)'
    notifies :reboot_now, 'reboot[emr_requires_reboot]'
  end

  reboot 'emr_requires_reboot' do
    reason 'Need to reboot when the selinux is enabled successfully.'
    not_if 'sestatus | grep permissive'
  end

when 'centos', 'redhat'
  bash 'enable_selinux_permissive' do
    code <<-EOH
    setenforce 0
    sed -i 's/SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
    sed -i 's/SELINUXTYPE=.*/SELINUXTYPE=targeted/' /etc/selinux/config
      EOH
    not_if '(sestatus | grep permissive) && (grep -q "SELINUX=permissive" /etc/selinux/config)'
    notifies :reboot_now, 'reboot[machine_requires_reboot]'
  end

  reboot 'machine_requires_reboot' do
    reason 'Need to reboot when the selinux is enabled successfully.'
    not_if 'sestatus | grep permissive'
  end
end
