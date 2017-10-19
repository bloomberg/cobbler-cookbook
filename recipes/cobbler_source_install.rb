#
# Cookbook Name:: cobblerd
# Recipe:: cobbler_source_install
#
# Copyright (C) 2017 Bloomberg Finance L.P.
#

cobbler_target_filepath = node['cobbler']['target']['filepath']

# Cobbler requires mod_version and mod_wsgi in its apache config. make sure
# Apache is installed and modules are configured
%w{apache2 libapache2-mod-wsgi}.each do |pkg|
  package pkg do
    action :install
  end
end

bash "a2enmod wsgi" do
  code "a2enmod wsgi"
  action :run
  not_if { ::File.exist?("/etc/apache2/mods-enabled/wsgi.load") }
  notifies :restart, 'service[apache2]', :immediately
end

service 'apache2' do
  action :nothing
end

# install cobbler

if node['cobbler']['package']['type'].downcase == 'local'
  cobbler_verify_cmd = 'dpkg-query -W -f=\'${Status}\' cobbler | grep -q \'^install ok installed$\''
  bash 'install cobbler' do
    code "dpkg -i #{cobbler_target_filepath} || apt-get install -yf && #{cobbler_verify_cmd}"
    not_if cobbler_verify_cmd
  end
else
  package 'cobbler' do
    version "#{node[:cobbler][:repo][:tag].gsub('v','')}-1"
  end
end

node.default['cobbler']['service']['name'] = 'cobblerd'

include_recipe 'cobblerd::web'
