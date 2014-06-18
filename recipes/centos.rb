#
# Cookbook Name:: cobblerd
# Recipe:: centos
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
include_recipe 'cobblerd::default'

filename = File.join('/var/lib/cobbler/kickstarts', 'redhat.ks')
template filename do
  source 'redhat.cfg.erb'
  not_if { File.exist? filename }
end

cobbler_image 'centos-6.5-x86_64-netinstall' do
  source 'http://mirror.es.its.nyu.edu/centos/6.5/isos/x86_64/CentOS-6.5-x86_64-netinstall.iso'
  checksum 'd8aaf698408c0c01843446da4a20b1ac03d27f87aad3b3b7b7f42c6163be83b9'
  os_breed 'redhat'
  os_version 'rhel6'
  os_kickstart filename
end

cobbler_image 'centos-5.10-x86_64-netinstall' do
  source 'http://mirror.es.its.nyu.edu/centos/5.10/isos/x86_64/CentOS-5.10-x86_64-netinstall.iso'
  checksum '87cdf657f3c1c0fdb77189f533d3df79bf0e36e6a797c2c145c61a00a0c6d0a2'
  os_breed 'redhat'
  os_version 'rhel5'
  os_kickstart filename
end
