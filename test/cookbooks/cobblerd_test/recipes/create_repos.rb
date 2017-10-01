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
  # The system is dependent on the repo.
  # NOTE: Do not mirror this locally because it will take a while and require a LOT of disk space.
  cobblerd_repo "centos-#{vers}" do
    comment "Mirror of CentOS #{vers} from kernel.org"
    mirror_url "http://mirrors.kernel.org/centos/#{vers}/os/x86_64/"
    clobber true
    action :create
  end
end
