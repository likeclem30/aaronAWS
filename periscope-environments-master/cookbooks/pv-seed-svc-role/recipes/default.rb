include_recipe 'pv_seed_svc::default'
include_recipe 'pv_seed_svc::nginx'
include_recipe 'pv_seed_assets::default'
include_recipe 'pv_seed_assets::nginx'
include_recipe 'mash-splunk::default'
