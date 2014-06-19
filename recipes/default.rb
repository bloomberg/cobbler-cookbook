#
# Cookbook Name:: cobblerd
# Recipe:: default
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
include_recipe 'chef-sugar::default'

include_recipe 'yum-epel::default' if rhel?
include_recipe 'apt::default' if debian?

package 'cobbler'
service 'cobbler' do
  action [:enable, :start]
  supports restart: true
end
