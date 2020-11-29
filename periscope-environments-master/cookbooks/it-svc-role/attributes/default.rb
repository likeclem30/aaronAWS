current_splunk_inputs = node['splunk'] && node['splunk']['inputs_conf'] && !node['splunk']['inputs_conf']['files'].empty? ? node['splunk']['inputs_conf']['files'] : []

splunk_inputs_for_it_svc = [{
  'filepath' => '/opt/periscope/impact-tracker-server/logs/ImpactTracker.json.log',
  'sourcetype' => 'impact-tracker',
},
                            {
                              'filepath' => '/opt/periscope/impact-tracker-server/logs/ImpactTracker.Healthcheck.json.log',
                              'sourcetype' => 'impact-tracker-health-check',
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

node.default['splunk']['inputs_conf']['files'] = splunk_inputs_for_it_svc + current_splunk_inputs
