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
