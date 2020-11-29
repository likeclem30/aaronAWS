databag_name = node['emr']['databag_name']
emr_config = data_bag_item(databag_name, node['emr']['databag_item'])
infra_config = data_bag_item(databag_name, node['infra']['databag_item'])
db_config = data_bag_item(databag_name, node['db']['databag_item'])
db_secrets = data_bag_item(databag_name, node['db']['secrets'])
install_dir = emr_config['install_dir']
versions = data_bag_item(databag_name, node['price']['services']['databag_item'])
calculation_engine_version = versions['calculation_engine_version']

jobserver_driver_memory = emr_config['jobserver_driver_memory']
jobserver_install_dir = emr_config['jobserver_install_dir']
jobserver_log_path = emr_config['jobserver_log_path']

directory install_dir do
  owner 'hadoop'
  group 'hadoop'
  mode '0755'
  action :create
  recursive true
end

cmd = Mixlib::ShellOut.new('curl http://169.254.169.254/latest/meta-data/local-hostname')
cmd.run_command
hostname = cmd.stdout

template "#{install_dir}/env.conf" do
  source 'env.conf.erb'
  variables(num_cpu_cores: emr_config['num_cpu_cores'],
            memory_per_node: emr_config['memory_per_node'],
            executor_instances: emr_config['executor_instances'],
            spark_home: emr_config['spark_home'],
            hdfs_name_node: hostname,
            install_dir: install_dir)
end

template "#{install_dir}/settings.sh" do
  source 'settings.sh.erb'
  variables(spark_home: emr_config['spark_home'],
            spark_conf_dir: emr_config['spark_conf_dir'],
            hadoop_conf_dir: emr_config['hadoop_conf_dir'],
            yarn_conf_dir: emr_config['yarn_conf_dir'],
            log_dir: emr_config['log_dir'])
end

db_server = db_config['db_server']
db_port = db_config['db_port']
db_instance = db_config['db_instance']
username = db_secrets['spark_user']
password = db_secrets['spark_password']

connection_string = "jdbc:sqlserver://#{db_server}:#{db_port};databasename=#{db_instance};username=#{username};password=#{password}"

template '/opt/periscope/application.conf' do
  source 'application.conf.erb'
  variables(connection_string: connection_string,
            dbtable: emr_config['dbtable'],
            recommendation_job_table: emr_config['recommendation_job_table'],
            partitions: emr_config['partitions'],
            engine_parameter_service_url: emr_config['engine_parameter_service_url'],
            calculation_engine_type: emr_config['calculation_engine_type'],
            calc_engine_data_service_url: emr_config['calc_engine_data_service_url'],
            calc_engine_output_url: emr_config['calc_engine_output_url'])
end

template "#{install_dir}/logback-server.xml" do
  source 'logback-server.xml.erb'
end

template "#{install_dir}/log4j-server.properties" do
  source 'log4j-server.properties.erb'
end

file "#{install_dir}/gc.out" do
  content '#gc.out'
  mode '0755'
  owner 'hadoop'
  group 'hadoop'
end

template '/etc/yum.repos.d/nexus.repo' do
  source 'nexus.repo.erb'
  variables(
    repo_name: node['nexus']['repo_name'],
    repo_url: infra_config['nexus_server_url'],
    gpgcheck: node['nexus']['gpgcheck'],
    is_enabled: node['nexus']['is_enabled']
  )
  notifies :run, 'execute[yum_clean_all]', :immediately
end

execute 'yum_clean_all' do
  command 'yum clean all && yum repolist'
end

yum_package 'spark-job-server' do
  version node['spark-job-server']['version-release']
  flush_cache [:before]
end

yum_package 'spark-dependent-jar' do
  version node['spark-job-server']['version-release']
  flush_cache [:before]
end

file "#{install_dir}/sqljdbc41.jar" do
  mode '0644'
end

hdfs_cmd = 'hdfs dfs -mkdir -p /user/hadoop/spark_jars
hdfs dfs -put -f /usr/lib/spark/lib/spark-assembly-1.5.2-hadoop2.6.0-amzn-2.jar  /user/hadoop/spark_jars/'

execute 'copy_spark_jar_to_hdfs' do
  command hdfs_cmd
end

yum_package 'calculation_engine' do
  version calculation_engine_version
  flush_cache [:before]
end

directory '/opt/periscope/spark-job-server/logs' do
  mode '0755'
  action :create
  recursive true
end

template '/etc/init.d/jobserver' do
  source 'jobserver.erb'
  mode '0755'
end

template '/opt/periscope/spark-job-server/jobserver_setup.sh' do
  source 'jobserver_setup.sh.erb'
  variables(
    jobserver_driver_memory: jobserver_driver_memory,
    jobserver_install_dir: jobserver_install_dir,
    jobserver_log_path: jobserver_log_path
  )
  notifies :start, 'service[jobserver]', :immediately
  mode '0755'
end

service 'jobserver' do
  supports start: true, enable: true
  action [:enable, :start]
end
