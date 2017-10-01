#
# Cookbook Name:: cobblerd
# Recipe:: default
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
# define cobbler sync for actions which need it
bash 'cobbler-sync' do
  code 'while ! cobbler repo list ; do sleep 1 ; done ; cobbler sync'
  action :nothing
end

include_recipe 'cobblerd::repos'
include_recipe 'cobblerd::server'
include_recipe 'cobblerd::nginx'
include_recipe 'cobblerd::uwsgi'
