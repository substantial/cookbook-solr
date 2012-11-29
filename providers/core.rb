action :create do
  Chef::Log.info new_resource.cookbook
  Chef::Log.info new_resource.cookbook_name
  Chef::Log.info new_resource.name

end
