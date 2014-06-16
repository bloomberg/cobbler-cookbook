#
# Cookbook Name:: cobblerd
# Recipe:: centos
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
include_recipe 'cobblerd::default'
return unless rhel?

filename = File.join('/var/lib/cobbler/kickstarts', 'redhat.ks')
template filename do
  source 'redhat.cfg.erb'
  variables({
  })
  not_if { File.exist? filename }
end

cobblerd_image 'centos-6.5-x86_64-netinstall' do
  source 'http://mirror.es.its.nyu.edu/centos/6.5/isos/x86_64/CentOS-6.5-x86_64-netinstall.iso'
  checksum 'd8aaf698408c0c01843446da4a20b1ac03d27f87aad3b3b7b7f42c6163be83b9'
end

cobblerd_image 'centos-5.10-x86_64-netinstall' do
  source 'http://mirror.es.its.nyu.edu/centos/5.10/isos/x86_64/CentOS-5.10-x86_64-netinstall.iso'
  checksum '87cdf657f3c1c0fdb77189f533d3df79bf0e36e6a797c2c145c61a00a0c6d0a2'
end

%w(centos-6.5-x86_64 centos-5.10-x86_64).each do |name|
  cobblerd_profile name do
    distro name
    kickstart filename
  end

  cobblerd_system name do
    image "#{name}-netinstall"
  end
end
