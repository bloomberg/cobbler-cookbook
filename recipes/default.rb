#
# Cookbook Name:: cobblerd
# Recipe:: default
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#

%w(loaders tasks config/distros.d config/profiles.d config/repos.d config/systems.d).each do |dir|
  directory File.join('/var/lib/cobbler/', dir) do
    owner 'root'
    group 'root'
    recursive true
  end
end

%w(/var/log/cobbler/tasks /var/www/cobbler /var/lib/tftpboot).each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    recursive true
  end
end

service node['cobbler']['service']['name'] do
  action [:enable, :start]
  supports restart: true
end

# define cobbler sync for actions which need it
bash 'cobbler-sync' do
  code 'cobbler sync'
  action :nothing
end
