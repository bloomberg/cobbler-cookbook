# rubocop:disable Style/SymbolArray
#
# Cookbook:: cobblerd
# Recipe:: nginx
#
# Copyright:: 2017, Specialty Manufacturing Company of South Carolina, All Rights Reserved
include_recipe 'nginx'
include_recipe 'nginx::http_stub_status_module'
include_recipe 'nginx::http_realip_module'

openssl_dhparam node['cobblerd']['http']['dhparams_file'] do
  key_length 2048
  generator 2
end

template "/etc/nginx/sites-available/#{node['cobblerd']['http']['server_name']}" do
  source 'nginx/site.conf.erb'
  owner node['nginx']['user']
  group node['nginx']['group']
  mode 0o0664
  notifies :reload, 'service[nginx]', :delayed
end

nginx_site node['cobblerd']['http']['server_name'] do
  action :enable
end

template "/etc/nginx/sites-available/#{node['cobblerd']['http']['server_name']}-ssl" do
  source 'nginx/ssl-site.conf.erb'
  owner node['nginx']['user']
  group node['nginx']['group']
  mode 0o0664
  notifies :reload, 'service[nginx]', :delayed
end

nginx_site "#{node['cobblerd']['http']['server_name']}-ssl" do
  action :enable
end

service 'nginx' do
  action [:enable, :start]
end
