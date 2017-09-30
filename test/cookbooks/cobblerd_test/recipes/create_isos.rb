#
# Cookbook Name:: cobblerd_test
# Recipe:: create_distros
#
# Copyright 2017, Justin Spies <justin@thespies.org>
#
# All rights reserved - Do Not Redistribute
#
# It is not automatically started.
profile = 'redhat'

%w(6.9 7.3.1611).each do |vers|
  osver = vers.gsub(/\.[0-9].*/, '')
  # The distros are dependent on the ISO having been downloaded.
  cobblerd_iso "centos-#{vers}-netinstall" do
    source "http://mirrors.kernel.org/centos/#{vers}/isos/x86_64/CentOS-#{osver}-x86_64-netinstall.iso"
    target "/var/www/cobbler/isos/CentOS-#{osver}-x86_64-netinstall.iso"
    action :delete
  end
end
