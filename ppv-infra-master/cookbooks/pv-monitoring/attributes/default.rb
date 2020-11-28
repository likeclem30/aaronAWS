default['monitoring']['versions']['databag_item'] = 'appversions'
default['monitoring']['component']['name'] = 'periscope-monitoring'
default['monitoring']['pcas']['databag_item'] = 'pcas'
default['monitoring']['url_context'] = 'app_context'
default['monitoring']['source_file'] = 'monitoring_config.erb'
default['monitoring']['services'] = [
  {
    'name' => 'PV Web',
    'url' => 'perf/healthcheck',
  }, {
    'name' => 'PV -> DB',
    'url' => 'perf/healthcheck/db',
  }, {
    'name' => 'PV -> SB Svc',
    'url' => 'perf/healthcheck/sbsvc',
  }, {
    'name' => 'PV -> PPT Svc',
    'url' => 'perf/healthcheck/pptsvc',
  }, {
    'name' => 'SB Web',
    'url' => 'sb/healthcheck',
  }, {
    'name' => 'SB Web -> Svc',
    'url' => 'sb/healthcheck/sbsvc',
  }, {
    'name' => 'SB Web -> DB',
    'url' => 'sb/healthcheck/db',
  }, {
    'name' => 'SB Web -> PPT Svc',
    'url' => 'sb/healthcheck/pptsvc',
  }, {
    'name' => 'Login',
    'url' => 'auth/healthcheck',
  }, {
    'name' => 'Login -> Token Svc',
    'url' => 'auth/healthcheck/token-service',
  }, {
    'name' => 'Impact-Tracker Server',
    'url' => 'action-workflow/api/healthcheck',
  }, {
    'name' => 'Impact-Tracker Server -> DB',
    'url' => 'action-workflow/api/healthcheck/db',
  }
]
