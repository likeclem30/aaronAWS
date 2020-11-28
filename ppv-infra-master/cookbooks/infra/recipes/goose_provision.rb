
yum_package 'goose' do
  version node['goose']['version-release']
  flush_cache [:before]
end
