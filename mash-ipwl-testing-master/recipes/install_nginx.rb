execute "apt-get update" do
  command "apt-get update"
end

execute "apt-get install libraries" do
  command "apt-get -y install --reinstall make build-essential libgd-dev libgeoip-dev libxslt1-dev libxml2-dev libxslt1.1 libpcre3 libpcre3-dev openssl libssl-dev  zlibc zlib1g zlib1g-dev perl libperl-dev"
end

package "install-nginx" do
  package_name 'nginx-extras'
  action :install
end


template '/usr/share/nginx/html/300.html' do
   source '300.html.erb'
end

template '/usr/share/nginx/html/50x.html' do
   source '50x.html.erb'
end

# Create folders inside nginx dir
nginx_dir = node['mash-ipwl-testing']['nginx_dir']
[nginx_dir+'/lua_files', nginx_dir+'/scripts', nginx_dir+'/maintenance', nginx_dir+'/ssl', nginx_dir+'/sites-enabled'].each do |nginx_subdir|
  directory nginx_subdir do
  end
end

#Create Folder inside share nginx folder
directory '/usr/ip' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end



#create script files for maintenance files and adding them in cron
  
file [nginx_dir+'/scripts/client_ip.sh'] do
  content '/usr/local/bin/aws s3 sync s3://ndm-ppv-npn-ipwl/stg/allowed_ips/ /usr/ip --exclude "global*" --exclude "*" --include "*com*" --sse=aws:kms --sse-kms-key-id arn:aws:kms:us-east-1:392164873763:key/3b955749-a93b-488a-b1c2-99cd24093eb4'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


file [nginx_dir+'/scripts/maintenance.sh'] do
  content '/usr/local/bin/aws s3 sync s3://ndm-ppv-npn-maintenance/ /etc/nginx/maintenance  --delete  --sse=aws:kms --sse-kms-key-id arn:aws:kms:us-east-1:392164873763:key/3b955749-a93b-488a-b1c2-99cd24093eb4'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

#Run script files
execute "client_ip.sh" do
  command "sh /etc/nginx/scripts/client_ip.sh "
end

execute "client_ip.sh" do
  command "sh /etc/nginx/scripts/maintenance.sh "
end

#Cron jobs for script files
cron 'maintenance' do
  command '/etc/nginx/scripts/maintenance.sh > /dev/null 2>&1'
  minute '*/2'
  hour '*'
  day '*'
  month '*'
  weekday '*'
  action :create
end

cron 'client_ip' do
  command '/etc/nginx/scripts/client_ip.sh > /dev/null 2>&1'
  minute '0'
  hour '8'
  day '*'
  month '*'
  weekday '*'
  action :create
end



execute "create-self-signed-certs" do
  command "openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout #{nginx_dir}/ssl/nginx.key -out #{nginx_dir}/ssl/nginx.crt -subj '/C=BE/ST=LLN/L=Portland/CN=snakeoil.mckinsey.com'"
  not_if "cat #{nginx_dir}/ssl/nginx.crt | grep CERTIFICATE"
end
