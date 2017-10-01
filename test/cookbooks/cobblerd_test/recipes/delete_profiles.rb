#
# Cookbook Name:: cobblerd_test
# Recipe:: create_distros
#
# Copyright 2017, Justin Spies <justin@thespies.org>
#
# All rights reserved - Do Not Redistribute
#
# It is not automatically started.
%w[6.9 7.3.1611].each do |vers| # rubocop:disable Metrics/BlockLength
  # Prep some files so that Cobbler doesn't complain...
  directory "/var/www/cobbler/images/centos-#{vers}" do
    owner 'root'
    group 'root'
    mode 0o0775
  end

  directory "/var/www/cobbler/images/centos-#{vers}/isolinux" do
    owner 'root'
    group 'root'
    mode 0o0775
  end

  %w[vmlinuz initrd.img].each do |file|
    remote_file "/var/www/cobbler/images/centos-#{vers}/isolinux/#{file}" do
      source 'file:///bin/cobbler'
      owner 'root'
      group 'root'
      mode 0o0775
    end
  end
  # End file Prep

  osmajor = vers.gsub(/\.[0-9].*/, '')

  if osmajor == '7'
    release = vers.gsub(/[0-9]*\.[0-9]*\.([0-9]*)/, '\1')
    source_file = "CentOS-#{osmajor}-x86_64-DVD-#{release}.iso"
  else
    source_file = "CentOS-#{vers}-x86_64-bin-DVD1.iso"
  end

  # The distros are dependent on the ISO having been downloaded.
  cobblerd_iso "centos-#{vers}-netinstall" do
    source "http://mirrors.kernel.org/centos/#{vers}/isos/x86_64/#{source_file}"
    target "/var/www/cobbler/isos/#{source_file}"
    action :import
  end

  # The profile is dependent on the distro.
  boot_file_hash = [{ '$img_path/': "/var/www/cobbler/images/centos-#{vers}/install.img" }]
  cobblerd_distro "centos-#{vers}" do
    kernel "/var/www/cobbler/images/centos-#{vers}/isolinux/vmlinuz"
    initrd "/var/www/cobbler/images/centos-#{vers}/isolinux/initrd.img"
    architecture 'x86_64'
    os_breed 'redhat'
    boot_files boot_file_hash
    os_version 'rhel7'
    comment "Test comment for 'distro-centos-#{vers}' distro"
    action :delete
  end

  # The system is dependent on the profile.
  cobblerd_profile "centos-#{vers}-minimal" do
    distro "centos-#{vers}"
    comment "Test profile for centos-#{vers}-minimal"
    action :delete
  end
end
