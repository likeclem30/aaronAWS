require 'chef/mixin/shell_out'

def cmd_success?(line)
  cmd = Mixlib::ShellOut.new(line)
  cmd.run_command
  cmd.exitstatus == 0
end
