current_splunk_inputs = node['splunk'] && node['splunk']['inputs_conf'] && !node['splunk']['inputs_conf']['files'].empty? ? node['splunk']['inputs_conf']['files'] : []

splunk_inputs_for_pv_web = [
  {
    'filepath' => '/opt/periscope/perf-web/logs/PerformanceAnalytics.json.log',
    'sourcetype' => 'perf-web',
  },
  {
    'filepath' => '/opt/periscope/perf-web/logs/PerformanceAnalytics-HealthCheck.json.log',
    'sourcetype' => 'perf-web-health-check',
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

node.default['splunk']['inputs_conf']['files'] = splunk_inputs_for_pv_web + current_splunk_inputs
