#
# Cookbook Name:: cobblerd
# Recipe:: default
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#

service 'cobbler' do
  case node['platform']
    when 'centos','redhat','fedora'
      if node['platform_version'].to_i >= 6
        service_name 'cobblerd'
      end
  end
  action [:enable, :start]
  supports restart: true
end

# define cobbler sync for actions which need it
bash 'cobbler-sync' do
  code 'cobbler sync'
  action :nothing
end
