current_splunk_inputs = node['splunk'] && node['splunk']['inputs_conf'] && !node['splunk']['inputs_conf']['files'].empty? ? node['splunk']['inputs_conf']['files'] : []

splunk_inputs_for_it_db = [{
  'filepath' => '/var/lib/pgsql/9.4/data/pg_log/',
  'sourcetype' => 'postgresql',
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

node.default['splunk']['inputs_conf']['files'] = splunk_inputs_for_it_db + current_splunk_inputs
