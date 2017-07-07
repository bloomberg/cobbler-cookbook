#
# Cookbook Name:: cobblerd_test
# Recipe:: create_distros
#
# Copyright 2017, Justin Spies <justin@thespies.org>
#
# All rights reserved - Do Not Redistribute
#
profile = 'redhat'

# Delete an existing distribution
cobblerd_distro "centos-existing" do
  action :delete
end

# Delete a non-existant distribution
cobblerd_distro "centos-non-existant" do
  action :delete
end
