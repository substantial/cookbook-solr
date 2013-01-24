action :create do
  core_name = new_resource.name
  solr_home = node['solr']['home']
  core_home = "#{solr_home}/#{core_name}"
  tomcat_user = node['tomcat']['user']
  tomcat_group = node['tomcat']['group']

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

  template "#{core_home}/conf/solrconfig.xml" do
    owner tomcat_user
    group tomcat_group
    source new_resource.config_source
    variables new_resource.config_variables

    notifies :restart, "service[tomcat]"
  end

  template "#{core_home}/conf/schema.xml" do
    owner tomcat_user
    group tomcat_group
    source new_resource.schema_source
    variables new_resource.schema_variables

    notifies :restart, "service[tomcat]"
  end
end
