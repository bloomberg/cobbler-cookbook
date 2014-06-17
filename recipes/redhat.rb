#
# Cookbook Name:: cobblerd
# Recipe:: redhat
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
include_recipe 'cobblerd::default'

filename = File.join('/var/lib/cobbler/kickstarts', 'redhat.ks')
template filename do
  source 'redhat.cfg.erb'
  variables({
    root_password: node[:cobbler][:root_password],
    user: node[:cobbler][:user]
  })
  not_if { File.exist? filename }
end

cobbler_image 'rhel-server-6.5-x86_64-boot' do
  source ''
  checksum 'b7a4f8b4d0132776ea20147abbb0a605d1a506ece92c704af5ab50796edc9a9b'
  os_breed 'redhat'
  os_version 'redhat'
  os_kickstart filename
end

cobbler_image 'rhel-server-6.5-x86_64-boot' do
  source ''
  checksum '31116987fb9f5161cd7a7c907d9acc57f832135faf55bb328d032fa6574e3f93'
  os_breed 'redhat'
  os_version 'rhel6'
  os_kickstart filename
end

cobbler_image 'rhel-server-5.10-x86_64-disc1' do
  source ''
  checksum 'cbfbae45ea08c268e6e45ce6c8a5e1c1a03f41e66d5ac7aeae26ba2b661db4bc'
  os_breed 'redhat'
  os_version 'rhel5'
  os_kickstart filename
end
