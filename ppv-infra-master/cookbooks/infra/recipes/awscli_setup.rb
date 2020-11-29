case node['platform_family']
when 'windows'
  windows_package 'aws-cli' do
    source node['aws-cli']['source']
  end
end
