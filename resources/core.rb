actions :create
default_action :create

attribute :schema_source, :kind_of => String, :default => "schema.xml.erb"
attribute :config_source, :kind_of => String, :default => "solrconfig.xml.erb"
