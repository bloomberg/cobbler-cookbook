# rubocop:disable Style/SymbolArray
#
# Cookbook:: cobblerd
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

template '/etc/uwsgi/cobbler_svc.ini' do
  source 'cobbler_svc.ini.erb'
  owner 'uwsgi'
  group 'uwsgi'
  mode 0o0664
end

%w[cobbler-web cobbler-svc].each do |svc|
  systemd_unit "#{svc}.service" do
    action :nothing
  end

  template "/lib/systemd/system/#{svc}.service" do
    source "#{svc}.service.erb"
    owner 'root'
    group 'root'
    mode 0o0664
    notifies :reload_or_restart, "systemd_unit[#{svc}.service]", :delayed
  end
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
