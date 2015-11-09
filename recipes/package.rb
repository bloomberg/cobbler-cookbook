#
# Cookbook Name:: cobblerd
# Recipe:: default
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
include_recipe 'yum-epel::default' if node[:platform_family] == "rhel"
include_recipe 'apt::default' if node[:platform_family] == "debian"

package 'cobbler'
