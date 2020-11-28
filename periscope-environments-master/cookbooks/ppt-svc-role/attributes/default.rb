current_splunk_inputs = node['splunk'] && node['splunk']['inputs_conf'] && !node['splunk']['inputs_conf']['files'].empty? ? node['splunk']['inputs_conf']['files'] : []

splunk_inputs_for_it_admin_svc = [
  {
    'filepath' => 'D:/Logs/PowerpointService/Powerpoint.Splunk.log',
    'sourcetype' => 'ppt-svc',
  },
]

node.default['splunk']['inputs_conf']['files'] = splunk_inputs_for_it_admin_svc + current_splunk_inputs
