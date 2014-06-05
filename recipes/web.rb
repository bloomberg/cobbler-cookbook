#
# Cookbook Name:: cobbler
# Recipe:: web
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#

include_recipe 'chef-sugar::default'

if rhel?
  return unless node[:platform_version] > 5
  include_recipe 'yum-epel::default'
end

package 'cobbler-web'
