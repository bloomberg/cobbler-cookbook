#
# Cookbook Name:: cobblerd
# Recipe:: web
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#

include_recipe 'cobblerd::default'

if rhel?
  return unless node[:platform_version].to_f > 5
  include_recipe 'yum-epel::default'
end

package 'cobbler-web'
