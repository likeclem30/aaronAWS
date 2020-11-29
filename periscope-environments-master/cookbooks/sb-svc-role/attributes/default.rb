current_splunk_inputs = node['splunk'] && node['splunk']['inputs_conf'] && !node['splunk']['inputs_conf']['files'].empty? ? node['splunk']['inputs_conf']['files'] : []

splunk_inputs_for_sb_svc = [
  {
    'filepath' => '/opt/periscope/sb-svc/logs/StoryboardService.json.log',
    'sourcetype' => 'sb-svc',
  },
  {
    'filepath' => '/opt/periscope/sb-svc/logs/StoryboardService.Health.json.log',
    'sourcetype' => 'sb-svc-health-check',
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

node.default['splunk']['inputs_conf']['files'] = splunk_inputs_for_sb_svc + current_splunk_inputs
