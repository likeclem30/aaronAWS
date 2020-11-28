current_splunk_inputs = node['splunk'] && node['splunk']['inputs_conf'] && !node['splunk']['inputs_conf']['files'].empty? ? node['splunk']['inputs_conf']['files'] : []

splunk_inputs_for_linux = [{
  'filepath' => '/var/log/messages',
  'sourcetype' => 'syslogs',
}]

node.default['splunk']['inputs_conf']['files'] = splunk_inputs_for_linux + current_splunk_inputs
