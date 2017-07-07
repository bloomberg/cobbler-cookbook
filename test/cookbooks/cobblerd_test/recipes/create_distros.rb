#
# Cookbook Name:: cobblerd_test
# Recipe:: create_distros
#
# Copyright 2017, Justin Spies <justin@thespies.org>
#
# All rights reserved - Do Not Redistribute
#
profile = 'redhat'

%w(6.9 7.3.1611).each do |vers|
  osver = vers.gsub(/\.[0-9].*/, '')
  boot_file_hash = [{'$img_path/': "/var/www/cobbler/images/centos-netinstall/install.img"}]

  cobblerd_distro "centos-#{vers}" do
    kernel "/var/www/cobbler/images/centos-#{vers}-netinstall/isolinux/vmlinuz"
    initrd "/var/www/cobbler/images/centos-#{vers}-netinstall/isolinux/initrd.img"
    boot_files boot_file_hash
    architecture 'x86_64'
    os_breed 'redhat'
    os_version 'rhel7'
    comment "Test comment for distro-centos-#{vers} distro"
    action :create
  end
end
