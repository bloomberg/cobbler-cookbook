#
# Cookbook Name:: cobblerd
# Recipe:: ubuntu
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
include_recipe 'cobblerd::default'

profile = 'ubuntu'

cobbler_image 'ubuntu-12.04-minimal' do
  source 'http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-amd64/current/images/netboot/mini.iso'
  checksum '7df121f07878909646c8f7862065ed7182126b95eadbf5e1abb115449cfba714'
  kernel 'http://archive.ubuntu.com/ubuntu/dists/precise-updates/main/installer-amd64/current/images/saucy-netboot/ubuntu-installer/amd64/linux'
  kernel_checksum '4664511047fc3d7d5d13be77a86141be05dca283b50a3a51fd3c0638ab72816d'
  initrd 'http://archive.ubuntu.com/ubuntu/dists/precise-updates/main/installer-amd64/current/images/saucy-netboot/ubuntu-installer/amd64/initrd.gz'
  initrd_checksum 'dbc5dafc6a4eb5f0c22fe85a79185d3761b76871b6501d82043361d5f3cc8e6d'
  os_version 'precise'
  os_breed 'ubuntu'
end

cobbler_image 'ubuntu-14.04-minimal' do
  source 'http://archive.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/current/images/netboot/mini.iso'
  checksum 'bc09966b54f91f62c3c41fc14b76f2baa4cce48595ce22e8c9f24ab21ac8d965'
  os_version 'trusty'
  os_breed 'ubuntu'
end

%w{ubuntu-12.04-minimal ubuntu-14.04-minimal}.each do |dist|
  cobbler_profile "#{profile}-#{dist}" do
    kickstart "#{profile}.preseed"
    distro "#{dist}-x86_64"
  end
end
