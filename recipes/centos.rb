#
# Cookbook Name:: cobblerd
# Recipe:: centos
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
include_recipe 'cobblerd::default'

profile = 'redhat'

cobbler_image 'centos-6.5-netinstall' do
  source 'http://mirror.es.its.nyu.edu/centos/6.5/isos/x86_64/CentOS-6.5-x86_64-netinstall.iso'
  checksum 'd8aaf698408c0c01843446da4a20b1ac03d27f87aad3b3b7b7f42c6163be83b9'
  os_breed 'redhat'
  os_version 'rhel6'
end

cobbler_image 'centos-5.10-netinstall' do
  source 'http://mirror.es.its.nyu.edu/centos/5.10/isos/x86_64/CentOS-5.10-x86_64-netinstall.iso'
  checksum '87cdf657f3c1c0fdb77189f533d3df79bf0e36e6a797c2c145c61a00a0c6d0a2'
  os_breed 'redhat'
  os_version 'rhel5'
end

%w{centos-6.5-netinstall centos-5.10-netinstall}.each do |dist|
  cobbler_profile "#{profile}-#{dist}" do
    kickstart "#{profile}.ks"
    distro "#{dist}-x86_64"
  end
end
