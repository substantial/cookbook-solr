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
