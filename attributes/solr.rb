#
# Cookbook Name:: solr
# Attributes:: default
#
# Copyright 2011, Substantial Inc
#
# All rights reserved - Do Not Redistribute
#

# Find solr version here @ https://archive.apache.org/dist/lucene/solr/
default['solr']['version'] = "4.2.0"
default['solr']['download_url'] = "https://archive.apache.org/dist/lucene/solr/4.2.0/solr-4.2.0.tgz"
default['solr']['download_md5'] = '334f8aef5b350f425fbdc21d37bf4604'
default['solr']['home'] = "/opt/solr"
default['solr']['cores'] = []
