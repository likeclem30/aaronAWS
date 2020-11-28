current_splunk_inputs = node['splunk'] && node['splunk']['inputs_conf'] && !node['splunk']['inputs_conf']['files'].empty? ? node['splunk']['inputs_conf']['files'] : []

splunk_inputs_for_it_admin_svc = [{
  'filepath' => '/opt/periscope/itracker-admin-service/logs/ITracker-Admin-Service.json.log',
  'sourcetype' => 'itracker-admin-service',
},
                                  {
                                    'filepath' => '/opt/periscope/itracker-admin-service/logs/ITracker-Admin-Service.Healthcheck.json.log',
                                    'sourcetype' => 'itracker-admin-service-health-check',
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

node.default['splunk']['inputs_conf']['files'] = splunk_inputs_for_it_admin_svc + current_splunk_inputs
