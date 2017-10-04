#
# Cookbook Name:: cobblerd_test
# Recipe:: create_distros
#
# Copyright 2017, Justin Spies <justin@thespies.org>
#
# All rights reserved - Do Not Redistribute
#
# It is not automatically started.

checksums = { '6.9' => 'd27cf37a40509c17ad70f37bc743f038c1feba00476fe6b69682aa424c399ea6' }


# Only delete the one ISO (7.3) so that a review of the web UI allows developers to see that 6.9 was downloaded
# and created.
checksums.each do |vers, sha256|
  # Variable setup.
  osmajor = vers.gsub(/\.[0-9].*/, '')

  dl_hostname = if node['cobblerd'].attribute?('iso_test_hostname') && !node['cobblerd']['iso_test_hostname'].empty?
                  node['cobblerd']['iso_test_hostname']
                else
                  'mirrors.kernel.org'
                end
  Chef::Log.info("Downloading ISOs from #{dl_hostname}")

  if osmajor == '7'
    release = vers.gsub(/[0-9]*\.[0-9]*\.([0-9]*)/, '\1')
    source_file = "CentOS-#{osmajor}-x86_64-DVD-#{release}.iso"
  else
    source_file = "CentOS-#{vers}-x86_64-bin-DVD1.iso"
  end

  # Delete the existing profile.
  cobblerd_system "system-#{vers}-delete" do
  #  profile "centos-#{vers}-minimal"
    action :delete
  end

  cobblerd_system "system-#{vers}-delete-missing" do
  #  profile "centos-#{vers}-minimal"
    action :delete
  end

  # Delete the existing profile.
  cobblerd_profile "profile-#{vers}-delete" do
    # distro "centos-#{vers}"
    # comment "Test profile for centos-#{vers}-minimal"
    action :delete
  end

  # Delete a non-existant profile.
  cobblerd_profile "profile-#{vers}-delete-missing" do
    # distro "centos-#{vers}"
    # comment "Test profile for centos-#{vers}-minimal"
    action :delete
  end

  # Delete an existing distribution
  cobblerd_distro "distro-#{vers}-delete" do
    action :delete
  end

  # Delete a non-existant distribution
  cobblerd_distro "distro-#{vers}-delete-missing" do
    action :delete
  end

  # NOTE: Do not mirror this locally because it will take a while and require a LOT of disk space.
  cobblerd_repo "repo-#{vers}-delete" do
    # comment "Mirror of CentOS #{vers} from kernel.org - to be deleted"
    # mirror_url "http://mirrors.kernel.org/centos/#{vers}/os/x86_64/"
    clobber true
    action :delete
  end

  cobblerd_repo "repo-#{vers}-delete-missing" do
    # comment "Mirror of CentOS #{vers} from kernel.org - to be deleted"
    # mirror_url "http://mirrors.kernel.org/centos/#{vers}/os/x86_64/"
    clobber true
    action :delete
  end

  cobblerd_image "image-#{vers}-delete" do
    # os_version 'rhel7'
    # architecture 'x86_64'
    # os_breed 'redhat'
    action :delete
  end

  cobblerd_image "image-#{vers}-delete-missing" do
    # os_version 'rhel7'
    # architecture 'x86_64'
    # os_breed 'redhat'
    action :delete
  end

  # The distros are dependent on the ISO having been downloaded.
  cobblerd_iso "iso-#{vers}" do
    # source "http://mirrors.kernel.org/centos/#{vers}/isos/x86_64/#{source_file}"
    # target "/var/www/cobbler/isos/#{source_file}"
    # checksum sha256
    action :delete
  end
end
