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

filename = node[:solr][:filename] || "apache-solr-#{node[:solr][:version]}.tgz"
download_url = node[:solr][:download_url] || "http://apache.cs.utah.edu//lucene/solr/#{node[:solr][:version]}/#{filename}"

bash "download and unzip solr" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget -c #{download_url}
  mkdir #{node[:solr][:path]}
  tar -zxvf #{filename} -C #{node[:solr][:path]}
  rm #{filename}
  EOH
  not_if "test -d #{node[:solr][:path]}/apache-solr-#{node[:solr][:version]}"
end
