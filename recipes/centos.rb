#
# Cookbook Name:: cobblerd
# Recipe:: centos
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
include_recipe 'cobblerd::default'

profile = 'redhat'

#cobbler_image 'centos-7.3-1611-minimal' do
#  source 'http://mirror.symnds.com/CentOS/7.3.1611/isos/x86_64/CentOS-7-x86_64-Minimal-1611.iso'
#  checksum '27bd866242ee058b7a5754e83d8ee8403e216b93d130d800852a96f41c34d86a'
#  os_breed 'redhat'
#  os_version 'rhel7'
#end

cobbler_image 'centos-6.8-minimal' do
  source 'http://mirror.symnds.com/CentOS/6.8/isos/x86_64/CentOS-6.8-x86_64-minimal.iso'
  checksum 'ec49c297d484b9da0787e5944edc38f7c70f21c0f6a60178d8e9a8926d1949f4'
  os_breed 'redhat'
  os_version 'rhel6'
end

#%w{centos-7.3.1611-minimal centos-6.8-minimal}.each do |dist|
%w{centos-6.8-minimal}.each do |dist|
  cobbler_profile "#{profile}-#{dist}" do
    kickstart "#{profile}.ks"
    distro "#{dist}-x86_64"
  end
end
