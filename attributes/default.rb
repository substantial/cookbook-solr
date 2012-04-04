#
# Cookbook Name:: solr
# Attributes:: default
#
# Copyright 2011, Substantial Inc
#
# All rights reserved - Do Not Redistribute
#


default[:solr][:version] = "3.4.0"
default[:solr][:filename] = "apache-solr-#{node[:solr][:version]}.tgz"
default[:solr][:download_url] = "http://apache.cs.utah.edu//lucene/solr/#{node[:solr][:version]}/#{node[:solr][:filename]}"
default[:solr][:path] = "/var/local/solr"
