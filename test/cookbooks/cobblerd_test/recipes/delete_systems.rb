#
# Cookbook Name:: cobblerd_test
# Recipe:: create_distros
#
# Copyright 2017, Justin Spies <justin@thespies.org>
#
# All rights reserved - Do Not Redistribute
#
# It is not automatically started.
%w[6.9 7.3.1611].each do |vers|
  cobblerd_system "something-to-delete-#{vers}" do
    profile "centos-#{vers}-minimal"
    action :delete
  end
end
