#
# Cookbook Name:: cobblerd
# Recipe:: ubuntu
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
include_recipe 'cobblerd::default'

filename = File.join('/var/lib/cobbler/kickstarts', 'ubuntu.ks')
template filename do
  source 'ubuntu.cfg.erb'
  variables({
    root_password: node[:cobbler][:root_password],
    user: node[:cobbler][:user]
  })
  not_if { File.exist? filename }
end

cobbler_image 'ubuntu-12.04-amd64-minimal' do
  source 'http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-amd64/current/images/netboot/mini.iso'
  checksum '7df121f07878909646c8f7862065ed7182126b95eadbf5e1abb115449cfba714'
  os_version 'precise'
  os_breed 'ubuntu'
  os_kickstart filename
end

cobbler_image 'ubuntu-14.04-amd64-minimal' do
  source 'http://archive.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/current/images/netboot/mini.iso'
  checksum 'bc09966b54f91f62c3c41fc14b76f2baa4cce48595ce22e8c9f24ab21ac8d965'
  os_version 'trusty'
  os_breed 'ubuntu'
  os_kickstart filename
end
