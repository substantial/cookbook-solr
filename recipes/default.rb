#
# Cookbook Name:: solr
# Recipe:: default
#
# Copyright 2011, Substantial Inc
#
# All rights reserved - Do Not Redistribute

class SolrVersionError < StandardError
  def initialize(msg= "Only supports 4.x. Please use solr-3.x branch")
    super(msg)
  end
end

include_recipe "java"
include_recipe "tomcat"

solr_version = node['solr']['version']

raise SolrVersionError if solr_version[0].to_i < 4

chef_cache_path = Chef::Config[:file_cache_path]
downloaded_filename = "solr-#{solr_version}.tgz"
download_url = node['solr']['download_url']
downloaded_solr_dir = File.join(chef_cache_path, "solr-#{solr_version}")
download_location = File.join(chef_cache_path, downloaded_filename)
solr_home = node['solr']['home']

tomcat_user = node['tomcat']['user']
tomcat_group = node['tomcat']['group']

execute "extract_solr" do
  cwd chef_cache_path
  command <<-EOS
    set -e
    tar -zxf #{downloaded_filename}
  EOS
  action :nothing
end

remote_file download_location do
  owner "root"
  source download_url
  mode "0644"
  action :create_if_missing
  notifies :run, 'execute[extract_solr]', :immediately
end

directory solr_home do
  owner tomcat_user
  group tomcat_group
  action :create
end

execute "reset_tomcat_cache" do
  command <<-EOS
    service tomcat6 stop
    touch #{node['tomcat']['home']}/conf/web.xml
    sudo rm -rf #{node['tomcat']['work_dir']}/*
  EOS
  action :nothing
  notifies :restart, "service[tomcat]"
end

downloaded_solr_war = "#{downloaded_solr_dir}/dist/solr-#{solr_version}.war"
current_solr_war = "#{solr_home}/solr.war"

execute "move solr stuff" do
  command <<-EOS
  cp -R #{downloaded_solr_war} #{current_solr_war}
  chown -R #{tomcat_user}:#{tomcat_group} #{solr_home}

  mkdir -p #{solr_home}/template/conf
  cp -R #{downloaded_solr_dir}/example/solr/collection1/conf/* #{solr_home}/template/conf
  chown -R #{tomcat_user}:#{tomcat_group} #{solr_home}
  EOS
  not_if do
    current_solr_md5 = Digest::MD5.file(current_solr_war).hexdigest
    downloaded_solr_md5 = Digest::MD5.file(downloaded_solr_war).hexdigest
    current_solr_md5 == downloaded_solr_md5
  end
  notifies :run, 'execute[reset_tomcat_cache]'
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
