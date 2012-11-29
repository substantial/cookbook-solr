#
# Cookbook Name:: solr
# Recipe:: default
#
# Copyright 2011, Substantial Inc
#
# All rights reserved - Do Not Redistribute
#
#

include_recipe "java"
include_recipe "tomcat"

filename = node[:solr][:filename] || "apache-solr-#{node[:solr][:version]}.tgz"
download_url = node[:solr][:download_url] || "http://apache.cs.utah.edu//lucene/solr/#{node[:solr][:version]}/#{filename}"
tomcat_user = node['tomcat']['user']
tomcat_group = node['tomcat']['group']
solr_home = node['solr']['home']

remote_file "/tmp/#{filename}" do
  owner "root"
  source download_url
  mode "0644"
  action :create_if_missing
end

# cookbook_file "/etc/tomcat6/Catalina/localhost/solr.xml" do
#   owner tomcat_user
# end

directory solr_home do
  owner tomcat_user
  group tomcat_group
  action :create
end

execute "extract_solr" do
  cwd "/tmp"
  command <<-EOS
    set -e

    cd /tmp
    tar -zxvf #{filename}

    cd /tmp/apache-solr-#{node['solr']['version']}

    mkdir -p #{solr_home}/template/conf
    cp -R example/solr/conf/* #{solr_home}/template/conf
    cp -R dist/apache-solr-*.war #{solr_home}/solr.war

    chown -R #{tomcat_user}:#{tomcat_group} #{solr_home}
  EOS

  creates "#{solr_home}/solr.war"

  #   cp dist/*.jar /usr/share/tomcat6/lib
  #   cp dist/solrj-lib/*.jar /usr/share/tomcat6/lib
  #   cp contrib/extraction/lib/* /usr/share/tomcat6/lib

  #   if [ ! -d /var/lib/tomcat6/webapps/solr/WEB-INF/lib ]; then
  #     sleep 5
  #   fi

  #   cp dist/*.jar /var/lib/tomcat6/webapps/solr/WEB-INF/lib
  #   cp dist/solrj-lib/*.jar /var/lib/tomcat6/webapps/solr/WEB-INF/lib

  #   chown -R #{tomcat_user}:#{tomcat_user} /var/lib/tomcat6/webapps/solr
  # EOS
  #creates "/var/lib/tomcat6/webapps/solr/WEB-INF/lib/apache-solr-cell-4.0.0.jar"
end

['core0', 'core1'].each do |core|
  core_home = "#{solr_home}/#{core}"

  directory core_home do
    owner tomcat_user
    group tomcat_group
  end

  execute "copy_conf" do
    command <<-EOS
      mkdir -p #{core_home}/conf
      cp -R #{solr_home}/template/conf/* #{core_home}/conf
      chown -R #{tomcat_user}:#{tomcat_group} #{core_home}
    EOS

    creates "#{core_home}/conf"
  end

  directory "#{core_home}/data" do
    owner tomcat_user
    group tomcat_group
    recursive true
  end

  template "#{core_home}/solrconfig.xml" do
    owner tomcat_user
    group tomcat_group
    source "solrconfig.xml.erb"
  end
end

template "#{solr_home}/solr.xml" do
  owner tomcat_user
  group tomcat_group
  source "solr.xml.erb"
end

template "#{node['tomcat']['context_dir']}/solr.xml" do
  owner tomcat_user
  group tomcat_group
  source "tomcat_solr.xml.erb"
  variables(
    :solr_home => solr_home
  )
end

  #template "#{node['solr']['home']}

# template "/opt/solr/collection1/conf/solrconfig.xml" do
#   owner "tomcat6"
#   source "solrconfig.xml.erb"
# end
# 
# template "/opt/solr/collection1/conf/schema.xml" do
#   owner "tomcat6"
#   source "schema.xml.erb"
#   notifies :run, "execute[restart-tomcat]"
# end
# 
# execute "restart-tomcat" do
#   command "/etc/init.d/tomcat6 restart"
#   action :nothing
# end
# 
# 
# 
# 
# 
# 
# 
# 
# bash "download and unzip solr" do
#   user "root"
#   cwd "/tmp"
#   code <<-EOH
#   curl #{download_url} > #{filename}
#   mkdir #{node[:solr][:path]}
#   tar -zxvf #{filename} -C #{node[:solr][:path]}
#   rm #{filename}
#   EOH
#   not_if "test -d #{node[:solr][:path]}/apache-solr-#{node[:solr][:version]}"
# end
