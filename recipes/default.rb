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

bash "download and unzip solr" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget -c #{node[:solr][:download_url]}
  mkdir #{node[:solr][:path]}
  tar -zxvf #{node[:solr][:filename]} -C #{node[:solr][:path]}
  rm #{node[:solr][:filename]}
  EOH
  not_if "test -d #{node[:solr][:path]}/apache-solr-#{node[:solr][:version]}"
end
