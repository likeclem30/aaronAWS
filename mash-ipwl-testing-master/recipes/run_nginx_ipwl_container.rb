def do_curl(client_ips, domain, http_header_name, location_name, expect_rejected)
  log ">> curl #{domain}#{location_name} with ip: #{client_ips} - Expect header ipwl-rejected #{expect_rejected}"
  execute 'nginx_configtest #{expect_rejected} result excepted' do
    retries 3
    if (expect_rejected)
      command "curl -I -H 'Host: #{domain}' -H '#{http_header_name}: #{client_ips}' http://127.0.0.1:8080#{location_name} | grep -q 'IPWL-rejected: true'"
    else 
      command "! curl -I -H 'Host: #{domain}' -H '#{http_header_name}: #{client_ips}' http://127.0.0.1:8080#{location_name} | grep -q 'IPWL-rejected: true'"
    end
  end
end

# Get node attributes
ecr_region = node['mash-ipwl-testing']['ecr_region']
ecr_registry_ids = node['mash-ipwl-testing']['ecr_registry_ids']
ecr_repo_uri = node['mash-ipwl-testing']['ecr_repo_uri']
nginx_dir = node['mash-ipwl-testing']['nginx_dir']
nginx_dir_temp = node['mash-ipwl-testing']['nginx_dir_temp']
container_name = node['mash-ipwl-testing']['container_name']
sites = node['mash-ipwl-testing']['sites']
sample_ips = node['mash-ipwl-testing']['sample_ips']
docker_tarball_url = node['mash-ipwl-testing']['docker_tarball_url']
docker_tarball_version = node['mash-ipwl-testing']['docker_tarball_version']
docker_tarball_checksum = node['mash-ipwl-testing']['docker_tarball_checksum']
mode_true_client_ip_header = node['mash-ipwl-testing']['mode_true_client_ip_header']

# Install docker
docker_installation_tarball 'default' do
  version docker_tarball_version
  source docker_tarball_url
  checksum docker_tarball_checksum
  action :create
end

# Play with docker
docker_service 'default' do
  action [:create, :start]
end

# Auth Docker with ECR registry
execute 'docker_login' do
  command "$(aws ecr get-login --registry-ids #{ecr_registry_ids} --region #{ecr_region})"
  #command "aws ecr get-login-password --region #{ecr_region} | docker login  --username AWS --password-stdin #{ecr_registry_ids}.dkr.ecr.us-east-1.amazonaws.com"
end

# Pull image (To make sure that we pull from ECR repo)
execute 'docker_pull_image' do
  command "docker pull #{ecr_repo_uri}"
  notifies :redeploy, "docker_container[#{container_name}]", :immediately
end

docker_container container_name do
  repo ecr_repo_uri #public image xdrum/nginx-extras
  port ['8080:80', '8443:443']
  volumes [
    nginx_dir_temp+':'+nginx_dir,
    '/sys/fs/cgroup:/sys/fs/cgroup:ro',
    '/usr/ip:/usr/ip',
    '/tmp/docker/log/nginx:/var/log/nginx',
    '/usr/share/lua/5.1/iputils.lua:/usr/share/lua/5.1/iputils.lua',
    '/usr/local/lib/lua/5.1/bit.so:/usr/local/lib/lua/5.1/bit.so'
  ]
  action :nothing
end

# Execute a curl only on http on each sample_ips + domain + location
sample_ips.each do |name_list, client_ips|
  sites.each do |name,site|
      site['locations'].each do |location|
      	
        # Check ipwl_bypass attr site
        if !(location.key?('ipwl_bypass') && location['ipwl_bypass'])
        
          # Regex url transformation for testing
          location_name = location['name'].tr("|","_").tr("()","")
          
            if location_name == "/vizql/"
               location_name = "/vizql/dummy.css"
          end
        
          if mode_true_client_ip_header || (location.key?('use_true_client_ip_header') && location['use_true_client_ip_header'])

            # Check the expect https status code
            if ['x-forwarded-for_reject_test1', 'x-forwarded-for_reject_test2'].include? name_list
              do_curl('100.100.100.100', site['domain'], 'True-Client-Ip', location_name, true) # means expect ipwl-rejected:true in the header
            else
              do_curl('80.231.198.178', site['domain'], 'True-Client-Ip', location_name, false)
            end
                      	
          else
          
            # Check the expect https status code
            if ['x-forwarded-for_reject_test1', 'x-forwarded-for_reject_test2'].include? name_list
              do_curl(client_ips, site['domain'], 'X-Forwarded-For', location_name, true) # means expect ipwl-rejected:true in the header
            else
              do_curl(client_ips, site['domain'], 'X-Forwarded-For', location_name, false)
            end
            
          end
          
        end
        
      end
  end
end

# Kill the container
docker_container container_name do
  action :kill
end
