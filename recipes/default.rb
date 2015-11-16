#
# Cookbook Name:: cobblerd
# Recipe:: default
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#

service node['cobbler']['service']['name'] do
  action [:enable, :start]
  supports restart: true
end

# define cobbler sync for actions which need it
bash 'cobbler-sync' do
  code 'cobbler sync'
  action :nothing
end
