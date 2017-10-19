#
# Cookbook Name:: cobblerd
# Recipe:: cobbler_package
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
include_recipe 'yum-epel::default' if node[:platform_family] == 'rhel'
include_recipe 'apt::default' if node[:platform_family] == 'debian'

node.default['cobbler']['service']['name'] = 'cobbler'

package 'cobbler'
package 'cobbler-web'

include_recipe 'cobblerd::web'
