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

# Upload basic kickstart configurations from cookbook templates.
%w(ubuntu redhat).each do |name|
  template "/var/lib/cobbler/kickstarts/chef-#{name}.ks" do
    source "#{name}.cfg.rb"
    variables({
      root_password: node[:cobbler][:root_password],
      user: {
        uid: node[:cobbler][:user][:uid],
        name: node[:cobbler][:user][:name],
        password: node[:cobbler][:user][:password]
      }
    })
  end
end if node[:cobbler][:use_cookbook_kickstarts]
