#
# Cookbook Name:: cobblerd
# Provider:: profile
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#

action :add do
  bash "cobbler profile add --name=#{new_resource.name} --kickstart=#{new_resource.kickstart} --distro=#{new_resource.distro}"
end

action :remove do
  bash "cobbler profile remove --name=#{new_resource.name}"
end
