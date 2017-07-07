#
# Cookbook Name:: cobblerd_test
# Recipe:: create_distros
#
# Copyright 2017, Justin Spies <justin@thespies.org>
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'cobblerd::default'

# It is not automatically started.
service 'httpd' do
  action [:enable, :start]
end

profile = 'redhat'

%w(6.9 7.3.1611).each do |vers|
  osver = vers.gsub(/\.[0-9].*/, '')
  # The distros are dependent on the ISO having been downloaded.
  cobblerd_iso "centos-#{vers}-netinstall" do
    source "http://mirrors.kernel.org/centos/#{vers}/isos/x86_64/CentOS-#{osver}-x86_64-netinstall.iso"
    target "/var/www/cobbler/isos/CentOS-#{osver}-x86_64-netinstall.iso"
    action :delete
  end

  # The profile is dependent on the distro.
  cobblerd_distro "centos-#{vers}" do
    kernel "/var/www/cobbler/images/centos-#{vers}-netinstall/isolinux/vmlinuz"
    initrd "/var/www/cobbler/images/centos-#{vers}-netinstall/isolinux/initrd.img"
    architecture 'x86_64'
    os_breed 'redhat'
    os_version 'rhel7'
    comment "Test comment for 'distro-centos-#{vers}' distro"
    action :create
  end

  # The system is dependent on the profile.
  cobblerd_profile "centos-#{vers}-minimal" do
    distro "centos-#{vers}"
    comment "Test profile for centos-#{vers}-minimal"
    action :create
  end
end
