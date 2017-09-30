#
# Cookbook Name:: cobblerd_test
# Recipe:: create_distros
#
# Copyright 2017, Justin Spies <justin@thespies.org>
#
# All rights reserved - Do Not Redistribute
#
# It is not automatically started.
profile = 'redhat'

%w(6.8 7.1).each do |vers|
  osver = vers.gsub(/\.[0-9]/, '')
  cobblerd_image "image-oul-#{vers}" do
    os_version 'rhel7'
    architecture 'x86_64'
    os_breed 'redhat'
    action :delete
  end
end