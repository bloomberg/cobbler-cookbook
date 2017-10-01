#
# Cookbook Name:: cobblerd_test
# Recipe:: create_distros
#
# Copyright 2017, Justin Spies <justin@thespies.org>
#
# All rights reserved - Do Not Redistribute
#
%w[6.9].each do |vers|
  # Delete an existing distribution
  cobblerd_distro "centos-#{vers}" do
    action :delete
  end
end

# Delete a non-existant distribution
cobblerd_distro "centos-non-existant" do
  action :delete
end
