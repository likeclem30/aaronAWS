#Lets install the Gem
chef_gem "aws-sdk" do
  action :install
  version "2.2.20"
end

require "aws-sdk"
require "digest"
require "ipaddr"


def expand_iprange(ip)
  a = IPAddr.new(ip)
  return a.to_range().to_a.map {|x| x.to_s }
end

def get_default_nameserver()
  nameservers = []
  # Find all the nameserver values in /etc/resolv.conf
  File.open("/etc/resolv.conf", "r").each_line do |line|
    if line =~ /^nameserver\s*(\S*)/
      nameservers << $1
    end
  end

  return nameservers[0]
end

def get_bucket_name(s3_config_path)
  return s3_config_path.split("/")[2]
end

def get_prefix_path(s3_config_path)
  return s3_config_path.split("/")[3..-1].join("/")
end

def get_csv_filename(csv_path)
  return csv_path.split("/")[-1].split(".csv")[0]
end

def get_domaine_name(csv_filename)
  return csv_filename.split("__")[0]
end

def get_location_name(csv_filename)
  location_name = "/"
  if (csv_filename.split("__").length > 1)
    location_name = "/"+csv_filename.split("__")[1].gsub("--","/")
  end 

  return location_name
end

# Setup node attributes
node.default['mash-ipwl-ppv']['default_nameserver'] = get_default_nameserver()

# Sites Config
if node['mash-ipwl-ppv']['sites_config'] == 'attribute'
  sites = node['mash-ipwl-ppv']['sites']
else
  s3 = Aws::S3::Client.new(:region => node['mash-ipwl-ppv']['s3_region'])

  sites = {}
  
  s3_sites_config = node['mash-ipwl-ppv']['s3_sites_config']
  bucket = get_bucket_name(s3_sites_config)
  prefix = get_prefix_path(s3_sites_config)

  l = s3.list_objects(bucket: bucket, prefix: prefix)
  l.contents.each do |site|
    resp = s3.get_object(bucket: bucket, key: site.key)
    resp_body = resp.body.read
    if (resp_body.length > 4)
      sites = sites.merge(JSON.parse(resp_body))
    end
  end
  # Set sites config in attribute node
  node.default['mash-ipwl-ppv']['sites'] = sites
end

# Secrets are unique by domain and are rotated daily
secrets = {}
app_domains = {}

sites.each do |name, site_props|
  secrets[site_props['domain']] = {}
  app_domains[site_props['domain']] = {}
  site_props['locations'].each do |location|
    secrets[site_props['domain']][location['name']] = Digest::SHA256.hexdigest(node['mash-ipwl-ppv']['secret_salt']+site_props['domain']+location['name']+Time.new.strftime("%Y-%m-%d"))
    app_domains[site_props['domain']][location['name']] = {}
  end
end

# IP Whitelist
if node['mash-ipwl-ppv']['ips_config'] == 'attribute'
  ip_whitelist = node['mash-ipwl-ppv']['ip_whitelist'].to_hash
  trusted_proxies = node['mash-ipwl-ppv']['trusted_proxies'].to_hash
  
  #Lets add empty locations and domains if not present so the configuration can compile in nginx
  app_domains.each do |domain,locations|
  	ip_whitelist[domain] ||= {}
  	trusted_proxies[domain] ||= {}

    locations.keys.each do |location|
      ip_whitelist[domain][location] ||= {"ips" => []}
      trusted_proxies[domain][location] ||= {"ips" => []}
    end
  end
else
  s3 = Aws::S3::Client.new(:region => node['mash-ipwl-ppv']['s3_region'])

  ip_whitelist = {}
  range_whitelist = {}
  global_whitelist = []
  global_range_whitelist = []

  ip_whitelist_config = node['mash-ipwl-ppv']['ip_whitelist_config']
  bucket = get_bucket_name(ip_whitelist_config)
  prefix = get_prefix_path(ip_whitelist_config)

  l = s3.list_objects(bucket: bucket, prefix: prefix)
  l.contents.each do |i|
    resp = s3.get_object(bucket: bucket, key: i.key)
    csv = resp.body.readlines

    log ">> Process CSV file: #{i.key}"

    csv.each do |line|
      csv_filename = get_csv_filename(i.key)
      domain_name = get_domaine_name(csv_filename)
      location_name = get_location_name(csv_filename)

      log ">> Read CSV line: #{line}"

      ip_with_range = line.split(",")[0]
      range_only = ip_with_range.split("/")[1].to_i

      if (range_only <= 24)
        if domain_name == "global"
          global_range_whitelist << ip_with_range
        else
          range_whitelist[domain_name] ||= {}
          range_whitelist[domain_name][location_name] ||= {}
          range_whitelist[domain_name][location_name]["ips"] ||= []
          range_whitelist[domain_name][location_name]["ips"] << ip_with_range

          # Tableau special behavior
          if (node['mash-ipwl-ppv']['mode_tableau'])
            range_whitelist[domain_name] ||= {}
            range_whitelist[domain_name]["/vizql/"] ||= {}
            range_whitelist[domain_name]["/vizql/"]["ips"] ||= []
            range_whitelist[domain_name]["/vizql/"]["ips"] << ip_with_range
          end
        end
      else
        ip_range = expand_iprange(ip_with_range)

        if domain_name == "global"
          global_whitelist += ip_range
        else
          ip_whitelist[domain_name] ||= {}
          ip_whitelist[domain_name][location_name] ||= {}
          ip_whitelist[domain_name][location_name]["ips"] ||= []
          ip_whitelist[domain_name][location_name]["ips"] += ip_range

          # Tableau special behavior
          if (node['mash-ipwl-ppv']['mode_tableau'])
            ip_whitelist[domain_name] ||= {}
            ip_whitelist[domain_name]["/vizql/"] ||= {}
            ip_whitelist[domain_name]["/vizql/"]["ips"] ||= []
            ip_whitelist[domain_name]["/vizql/"]["ips"] += ip_range
          end
        end
      end
    end
  end
  
  # Lets add empty locations and domains if not present so the configuration can compile in nginx
  app_domains.each do |domain,locations|
    ip_whitelist[domain] ||= {}
    locations.keys.each do |location|
      ip_whitelist[domain][location] ||= {"ips" => []}
    end

    range_whitelist[domain] ||= {}
    locations.keys.each do |location|
      range_whitelist[domain][location] ||= {"ips" => []}
    end
  end
  
  # Adding global IPs to each specific location
  (ip_whitelist.keys+app_domains.keys).uniq.each do |domain|
    ip_whitelist[domain] ||= {"/" => {"ips" => global_whitelist}}
    ip_whitelist[domain].keys.each do |location|
       ip_whitelist[domain][location]["ips"] += global_whitelist
    end
  end
  
  # Adding global range IPs to each specific location
  (range_whitelist.keys+app_domains.keys).uniq.each do |domain|
    range_whitelist[domain] ||= {"/" => {"ips" => global_range_whitelist}}
    range_whitelist[domain].keys.each do |location|
       range_whitelist[domain][location]["ips"] += global_range_whitelist
    end
  end


  
  # Trusted Proxies
  trusted_proxies = {}
  global_proxies = []
  
  trusted_proxies_config = node['mash-ipwl-ppv']['trusted_proxies_config']
  bucket = get_bucket_name(trusted_proxies_config)
  prefix = get_prefix_path(trusted_proxies_config)

  l = s3.list_objects(bucket: bucket, prefix: prefix)
  l.contents.each do |i|
    csv_filename = get_csv_filename(i.key)
    domain_name = get_domaine_name(csv_filename)
    location_name = get_location_name(csv_filename)
    
    resp = s3.get_object(bucket: bucket, key: i.key)
    csv = resp.body.readlines
    csv.each do |line|
      if domain_name == "global"
        global_proxies += expand_iprange(line.split(",")[0])
      else
        trusted_proxies[domain_name] ||= {}
        trusted_proxies[domain_name][location_name] ||= {}
        trusted_proxies[domain_name][location_name]["ips"] ||= []
        trusted_proxies[domain_name][location_name]["ips"] += expand_iprange(line.split(",")[0])
      end
    end
  end
  
   #Lets add empty locations and domains if not present so the configuration can compile in nginx
  app_domains.each do |domain,locations|
    trusted_proxies[domain] ||= {}
    locations.keys.each do |location|
      trusted_proxies[domain][location] ||= {"ips" => []}
    end
  end
  
  #Adding global IPs
  (trusted_proxies.keys+app_domains.keys).uniq.each do |domain|
    trusted_proxies[domain] ||= {"/" => {"ips" => global_proxies}}
    trusted_proxies[domain].keys.each do |location|
      trusted_proxies[domain][location]["ips"] += global_proxies
    end
  end
  
end

# Copy all files from existing nginx config folder
nginx_dir = node['mash-ipwl-ppv']['nginx_dir']
nginx_dir_temp = node['mash-ipwl-ppv']['nginx_dir_temp']
directory nginx_dir_temp do
end

execute 'cp_nginx_conf' do
  command "cp -R #{nginx_dir}/* #{nginx_dir_temp}"
end

# Clean folders inside nginx-ipwl dirs
[nginx_dir_temp+'/lua_files', nginx_dir_temp+'/sites-enabled'].each do |nginx_subdir|
  execute 'clean_nginx_ipwl_conf' do
    command "rm -rf #{nginx_subdir}/*"
  end
end

template nginx_dir_temp+'/lua_files/ip_whitelist.lua' do
    source 'ip_whitelist.lua.erb'
    variables({
      :ip_whitelist => ip_whitelist,
      :trusted_proxies => trusted_proxies,
      :secrets => secrets
    })
end

template nginx_dir_temp+'/lua_files/range_whitelist.lua' do
    source 'range_whitelist.lua.erb'
    variables({
      :range_whitelist => range_whitelist
    })
end

template nginx_dir_temp+'/sites-enabled/default' do
    source 'default.erb'
    variables({
      :default_url => node['mash-ipwl-ppv']['default_url'],
      :ipwl_atts => node['mash-ipwl-ppv']
    })
end

# Site files for nginx/sites-enabled
sites.each do |name, site|
  template nginx_dir_temp+"/sites-enabled/#{site['domain']}" do
    source site['type']+'.erb'
    variables({
        :site => site,
        :default_url => node['mash-ipwl-ppv']['default_url'],
        :default_nameserver => node['mash-ipwl-ppv']['default_nameserver'],
        :ipwl_atts => node['mash-ipwl-ppv'],
    })
  end

  site['locations'].each do |location|
    if location['tenant_id'] and location['502_custom_page']
      template "/usr/share/nginx/html/502_#{location['tenant_id']}_#{location['name'].gsub('/','l_')}.html" do
         source '502.html.erb'
         variables({
           :site => site,
           :location => location,
         })
      end
    end
  end

end

# nginx.conf file
template nginx_dir_temp+'/nginx.conf' do
  source 'nginx.conf.erb'
  variables({
    :ipwl_atts => node['mash-ipwl-ppv']
  })
end
