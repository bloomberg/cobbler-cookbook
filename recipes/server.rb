# rubocop:disable Style/SymbolArray
#
# Cookbook:: cobblerd
# Recipe:: nginx
#
# Copyright:: 2017, Specialty Manufacturing Company of South Carolina, All Rights Reserved
package 'cobbler'
package 'cobbler-web'

template '/etc/cobbler/auth.conf' do
  source 'cobbler/auth.conf.erb'
  owner 'root'
  group 'root'
  mode 0o0664
end

template '/etc/cobbler/settings' do
  source 'cobbler/settings.erb'
  owner 'root'
  group 'root'
  mode 0o0664
end

template '/etc/cobbler/modules.conf' do
  source 'cobbler/modules.conf.erb'
  owner 'root'
  group 'root'
  mode 0o0664
end

template '/etc/cobbler/users.conf' do
  source 'cobbler/users.conf.erb'
  owner 'root'
  group 'root'
  mode 0o0664
end

service 'cobbler' do
  case node['platform']
  when 'centos', 'redhat', 'fedora', 'oracle'
    service_name 'cobblerd' if node['platform_version'].to_i >= 6
  end
  action [:enable, :start]
  supports restart: true
end

ruby_block 'Write /etc/cobbler/users.digest' do
  block do
    require 'webrick'
    file = ::WEBrick::HTTPAuth::Htdigest.new '/etc/cobbler/users.digest'
    file.set_passwd 'Cobbler',
                    node['cobblerd']['web_username'],
                    node['cobblerd']['web_password']
    file.flush
  end
  notifies :restart, 'service[cobbler]', :delayed
end
