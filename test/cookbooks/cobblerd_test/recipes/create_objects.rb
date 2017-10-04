#
# Cookbook Name:: cobblerd_test
# Recipe:: create_distros
#
# Copyright 2017, Justin Spies <justin@thespies.org>
#
# All rights reserved - Do Not Redistribute
#
# It is not automatically started.

checksums = { '6.9' => 'd27cf37a40509c17ad70f37bc743f038c1feba00476fe6b69682aa424c399ea6',
              '7.4.1708' => 'ec7500d4b006702af6af023b1f8f1b890b6c7ee54400bb98cef968b883cd6546' }

checksums.each do |vers, sha256|
  # Variable setup.
  osmajor = vers.gsub(/\.[0-9].*/, '')
  next unless osmajor == '6'

  dl_hostname = if node['cobblerd'].attribute?('iso_test_hostname') && !node['cobblerd']['iso_test_hostname'].empty?
                  node['cobblerd']['iso_test_hostname']
                else
                  'mirrors.kernel.org'
                end
  Chef::Log.info("Downloading ISOs from #{dl_hostname}")

  if osmajor == '7'
    release = vers.gsub(/[0-9]*\.[0-9]*\.([0-9]*)/, '\1')
    source_file = "CentOS-#{osmajor}-x86_64-DVD-#{release}.iso"
    # source_file = "centos-#{vers.gsub(/([0-9]*\.[0-9]*)\.[0-9]*/, '\1')}-small-x86_64.iso"
  else
    source_file = "CentOS-#{vers}-x86_64-bin-DVD1.iso"
    # source_file = "centos-#{vers}-small-x86_64.iso"
  end

  # The distros are dependent on the ISO having been downloaded, so get the ISOs setup here.
  cobbler_iso "iso-#{vers}" do
    source "http://192.168.86.35/centos/6.9/isos/x86_64/#{source_file}"
    target "/data/isos/#{source_file}"
    checksum sha256
    action :download
  end

  cobbler_image "image-#{vers}" do
    target "/data/isos/#{source_file}"
    os_breed 'redhat'
    action :import
  end

  # Test the image setup; these are not dependent on anything else.
  cobbler_image "image-#{vers}-delete" do
    os_version 'rhel7'
    architecture 'x86_64'
    os_breed 'redhat'
    action :create
  end

  # Test the image setup; these are not dependent on anything else.
  cobbler_image "image-#{vers}-leave" do
    os_version 'rhel7'
    architecture 'x86_64'
    os_breed 'redhat'
    action :create
  end

  # The system is dependent on the repo.
  # NOTE: Do not mirror this locally because it will take a while and require a LOT of disk space.
  cobbler_repo "repo-#{vers}-delete" do
    comment "Mirror of CentOS #{vers} from kernel.org - to be deleted"
    mirror_url "http://mirrors.kernel.org/centos/#{vers}/os/x86_64/"
    clobber true
    action :create
  end

  # The system is dependent on the repo.
  # NOTE: Do not mirror this locally because it will take a while and require a LOT of disk space.
  cobbler_repo "repo-#{vers}-leave" do
    comment "Mirror of CentOS #{vers} from kernel.org - to be left in place"
    mirror_url "http://mirrors.kernel.org/centos/#{vers}/os/x86_64/"
    clobber true
    action :create
  end

  boot_file_hash = [{ '$img_path/': "/var/www/cobbler/images/iso-#{vers}-x86_64/install.img" }]
  cobbler_distro "distro-#{vers}-delete" do
    kernel "/var/www/cobbler/images/image-#{vers}-x86_64/vmlinuz"
    initrd "/var/www/cobbler/images/image-#{vers}-x86_64/initrd.img"
    boot_files boot_file_hash
    architecture 'x86_64'
    os_breed 'redhat'
    os_version 'rhel7'
    comment "Test comment for distro-#{vers} distro"
    action :create
  end

  cobbler_distro "distro-#{vers}-leave" do
    kernel "/var/www/cobbler/images/image-#{vers}-x86_64/vmlinuz"
    initrd "/var/www/cobbler/images/image-#{vers}-x86_64/initrd.img"
    boot_files boot_file_hash
    architecture 'x86_64'
    os_breed 'redhat'
    os_version 'rhel7'
    comment "Test comment for distro-#{vers} distro"
    action :create
  end

  # The profile is dependent on the distro.
  cobbler_profile "profile-#{vers}-delete" do
    distro "distro-#{vers}-delete"
    comment "Deletable test profile for centos-#{vers}"
    action :create
  end

  cobbler_profile "profile-#{vers}-leave" do
    distro "distro-#{vers}-leave"
    comment "Test profile to be kept for centos-#{vers}"
    action :create
  end

  cobbler_system "system-#{vers}-delete" do
    profile "profile-#{vers}-delete"
    action :create
  end

  cobbler_system "system-#{vers}-leave" do
    profile "profile-#{vers}-leave"
    action :create
  end

end
