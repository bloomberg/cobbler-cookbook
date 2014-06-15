#
# Cookbook Name:: cobblerd
# Provider:: system
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
action :add do
  name = new_resource.name
  mac_address = new_resource.mac_address
  image = new_resource.image

  bash "cobbler system add --name=#{name} --mac=#{mac_address} --image=#{image}"
end

action :remove do
  bash "cobbler system remove --name=#{new_resource.name}"
end
