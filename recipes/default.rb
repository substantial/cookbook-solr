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

solr_version = node['solr']['version']

filename = "solr-#{solr_version}.tgz"
download_url = node['solr']['download_url']
download_md5 = node['solr']['download_md5']
solr_home = node['solr']['home']

tomcat_user = node['tomcat']['user']
tomcat_group = node['tomcat']['group']

remote_file "/tmp/#{filename}" do
  owner "root"
  source download_url
  checksum download_md5
  mode "0644"
end

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
    tar -zxf #{filename}
  EOS

  not_if { Dir.exists?("/tmp/#{filename}") }
end

downloaded_solr_war = "/tmp/#{filename}/dist/solr-#{solr_version}.war"
current_solr_war = "#{solr_home}/solr.war"

def different_solr_version?
  @different_version ||=begin
    current_solr_md5 = Digest::MD5.file(current_solr_war).hexdigest
    downloaded_solr_md5 =  Digest::MD5.file(downloaded_solr_war).hexdigest
    current_solr_md5 == downloaded_solr_md5
  end
end

execute "move solr" do
  command <<-EOS
    cp -R #{downloaded_solr_war} #{current_solr_war}
    chown -R #{tomcat_user}:#{tomcat_group} #{solr_home}
  EOS
  only_if { different_solr_version? }
end

execute "create template conf" do
  command <<-EOS
    mkdir -p #{solr_home}/template/conf
    cp -R /tmp/#{filename}/example/solr/collection1/conf/* #{solr_home}/template/conf
    chown -R #{tomcat_user}:#{tomcat_group} #{solr_home}
  EOS
  only_if { different_solr_version? }
end

template "#{solr_home}/solr.xml" do
  owner tomcat_user
  group tomcat_group
  source "solr.xml.erb"
  variables(
    :cores => node['solr']['cores']
  )

  notifies :restart, "service[tomcat]"
end

template "#{node['tomcat']['context_dir']}/solr.xml" do
  owner tomcat_user
  group tomcat_group
  source "tomcat_solr.xml.erb"
  variables(
    :solr_home => solr_home
  )
end
