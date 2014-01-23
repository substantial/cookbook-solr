actions :create
default_action :create

attribute :schema_source, :kind_of => String, :default => "schema.xml.erb"
attribute :schema_variables, :kind_of => Hash, :default => {}
attribute :config_source, :kind_of => String, :default => "solrconfig.xml.erb"
attribute :config_variables, :kind_of => Hash, :default => {}
