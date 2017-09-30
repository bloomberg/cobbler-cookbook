# rubocop:disable Style/SymbolArray
#
# Cookbook:: psmc_cobbler
# Recipe:: uwsgi
#
# Copyright:: 2017, Specialty Manufacturing Company of South Carolina, All Rights Reserved
package 'uwsgi'
package 'uwsgi-plugin-python'

directory '/etc/uwsgi' do
  owner 'uwsgi'
  group 'uwsgi'
  mode 0o0775
end

template '/etc/uwsgi/cobbler_web.ini' do
  source 'cobbler_web.ini.erb'
  owner 'uwsgi'
  group 'uwsgi'
  mode 0o0664
end

template '/lib/systemd/system/cobbler-web.service' do
  source 'cobbler-web.service.erb'
  owner 'root'
  group 'root'
  mode 0o0664
end

template '/etc/uwsgi/cobbler_svc.ini' do
  source 'cobbler_svc.ini.erb'
  owner 'uwsgi'
  group 'uwsgi'
  mode 0o0664
end

template '/lib/systemd/system/cobbler-svc.service' do
  source 'cobbler-svc.service.erb'
  owner 'root'
  group 'root'
  mode 0o0664
end

service 'uwsgi' do
  action [:enable, :start]
end

service 'cobbler-web' do
  action [:enable, :start]
end

service 'cobbler-svc' do
  action [:enable, :start]
end
