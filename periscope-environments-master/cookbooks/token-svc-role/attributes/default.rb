current_splunk_inputs = node['splunk'] && node['splunk']['inputs_conf'] && !node['splunk']['inputs_conf']['files'].empty? ? node['splunk']['inputs_conf']['files'] : []

splunk_inputs_for_token_svc = [
  {
    'filepath' => '/opt/periscope/token-service/logs/Token-service.json.log',
    'sourcetype' => 'token-service',
  },
  {
    'filepath' => '/opt/periscope/token-service/logs/Token-service-health.json.log',
    'sourcetype' => 'token-service-health-check',
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

node.default['splunk']['inputs_conf']['files'] = splunk_inputs_for_token_svc + current_splunk_inputs
