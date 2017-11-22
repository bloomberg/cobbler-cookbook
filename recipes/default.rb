#
# Cookbook Name:: cobblerd
# Recipe:: default
#
# Copyright:: 2017, Justin Spies, All Rights Reserved
#
# define cobbler sync for actions which need it
bash 'cobbler-sync' do
  code 'while ! cobbler repo list ; do sleep 1 ; done ; cobbler sync'
  action :nothing
end

include_recipe 'cobblerd::repos'
include_recipe 'cobblerd::nginx' if node['cobblerd']['http_service_name'] == 'nginx'
include_recipe 'cobblerd::apache' if node['cobblerd']['http_service_name'] == 'httpd'
include_recipe 'cobblerd::server'
# This relies on certain cobbler files having been installed so it must be run after both the 'nginx' 
# and the 'server' recipes.
include_recipe 'cobblerd::uwsgi' if node['cobblerd']['http_service_name'] == 'nginx'
