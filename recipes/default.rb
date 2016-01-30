#
# Cookbook Name:: cobblerd
# Recipe:: default
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
include_recipe 'yum-epel::default' if node[:platform_family] == "rhel"
include_recipe 'apt::default' if node[:platform_family] == "debian"
include_recipe 'cobblerd::apache' if node[:cobbler][:include_apache2]

package 'cobbler'
package 'syslinux'

service 'cobbler' do
  action [:enable, :start]
  supports restart: true
end

# define cobbler sync for actions which need it
bash 'cobbler-sync' do
  command 'cobbler sync'
  action :nothing
end
