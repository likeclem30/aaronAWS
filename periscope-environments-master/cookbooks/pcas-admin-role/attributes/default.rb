current_splunk_inputs = node['splunk'] && node['splunk']['inputs_conf'] && !node['splunk']['inputs_conf']['files'].empty? ? node['splunk']['inputs_conf']['files'] : []

splunk_inputs_for_pcas_admin = [{
  'filepath' => '/opt/periscope/login-web/logs/Auth-Login.json.log',
  'sourcetype' => 'login-web',
},
                                {
                                  'filepath' => '/opt/periscope/login-web/logs/Auth-Login-health.json.log',
                                  'sourcetype' => 'login-web-health-check',
                                },
                                {
                                  'filepath' => '/opt/periscope/pcas-admin/logs',
                                  'sourcetype' => 'pcas-admin',
                                },
                                {
                                  'filepath' => '/var/log/nginx',
                                  'sourcetype' => 'price-admin-nginx',
                                },
                                {
                                  'filepath' => '/var/log/audit/audit.log',
                                  'sourcetype' => 'auditlog',
                                },
                                {
                                  'filepath' => '/var/log/messages',
                                  'sourcetype' => 'syslogs',
                                }]

node.default['splunk']['inputs_conf']['files'] = splunk_inputs_for_pcas_admin + current_splunk_inputs
