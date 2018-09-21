#
# Cookbook Name:: cobblerd
# Recipe:: ubuntu
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
include_recipe 'cobblerd::default'

profile = 'ubuntu'

cobbler_image 'ubuntu-14.04-minimal' do
  source 'http://archive.ubuntu.com/ubuntu/dists/trusty-updates/main/installer-amd64/current/images/xenial-netboot/mini.iso'
  checksum 'eefab8ae8f25584c901e6e094482baa2974e9f321fe7ea7822659edeac279609'
  os_version 'trusty'
  os_breed 'ubuntu'
end

%w{ubuntu-14.04-minimal}.each do |dist|
  cobbler_profile "#{profile}-#{dist}" do
    kickstart "#{profile}.preseed"
    distro "#{dist}-x86_64"
  end
end
