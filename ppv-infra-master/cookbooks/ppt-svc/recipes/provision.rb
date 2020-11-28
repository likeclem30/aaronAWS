nuget_install node['ppt-svc']['nuget_install_path']

%w( IIS-WebServerRole IIS-WebServer NetFx4Extended-ASPNET45 IIS-NetFxExtensibility45 IIS-ISAPIExtensions IIS-ISAPIFilter
    IIS-ASPNET45).each do |feature|
  windows_feature feature do
    action :install
  end
end

iis_site 'Default Web Site' do
  action [:stop]
end

iis_pool 'PptService' do
  runtime_version '4.0'
  pipeline_mode :Integrated
  action :add
end

iis_site 'Ppt Service' do
  application_pool 'PptService'
  protocol :http
  port 80
  path 'C:/periscope/PowerpointService'
  action [:add, :start]
end
