current_splunk_inputs = node['splunk'] && node['splunk']['inputs_conf'] && !node['splunk']['inputs_conf']['files'].empty? ? node['splunk']['inputs_conf']['files'] : []

splunk_inputs_for_sb_web = [
  {
    'filepath' => '/opt/periscope/sb-web/logs/StoryboardWeb.json.log',
    'sourcetype' => 'sb-web',
  },
  {
    'filepath' => '/opt/periscope/sb-web/logs/StoryboardWeb.Health.json.log',
    'sourcetype' => 'sb-web-health-check',
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

node.default['splunk']['inputs_conf']['files'] = splunk_inputs_for_sb_web + current_splunk_inputs
