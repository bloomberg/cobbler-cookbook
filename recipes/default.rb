#
# Cookbook Name:: cobblerd
# Recipe:: default
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
service 'cobbler' do
  case node['platform']
  when 'centos', 'redhat', 'fedora', 'oracle'
    service_name 'cobblerd' if node['platform_version'].to_i >= 6
  end
  action [:enable, :start]
  supports restart: true
end

# define cobbler sync for actions which need it
bash 'cobbler-sync' do
  code 'cobbler sync'
  action :nothing
end

include_recipe 'cobblerd::repos'
include_recipe 'cobblerd::server'
include_recipe 'cobblerd::nginx'
include_recipe 'cobblerd::uwsgi'
