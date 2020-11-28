current_splunk_inputs = node['splunk'] && node['splunk']['inputs_conf'] && !node['splunk']['inputs_conf']['files'].empty? ? node['splunk']['inputs_conf']['files'] : []

splunk_inputs_for_pv_seed_svc = [{
  'filepath' => '/opt/periscope/landingpage-seed/logs',
  'sourcetype' => 'landingpage-seed',
},
                                 {
                                   'filepath' => '/var/log/audit/audit.log',
                                   'sourcetype' => 'auditlog',
                                   'index' => 'audit',
                                 },
                                 {
                                   'filepath' => '/var/log/messages',
                                   'sourcetype' => 'syslogs',
                                 }]

node.default['splunk']['inputs_conf']['files'] = splunk_inputs_for_pv_seed_svc + current_splunk_inputs
