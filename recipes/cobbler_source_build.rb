#
# Cookbook Name:: cobblerd
# Recipe:: cobbler_source_build
#
# Copyright (C) 2017 Bloomberg Finance L.P.
#

build_user = node['cobbler']['source']['build_user']
build_group = node['cobbler']['source']['build_group']

source_code_root = node['cobbler']['source']['dir']

cobbler_code_location = "#{source_code_root}/cobbler"

cobbler_target_filepath = node['cobbler']['target']['filepath']

# cobbler build dependencies
%w{git
   gcc
   make
   pyflakes
   pep8
   python-sphinx
   python-cheetah
   python-yaml
   python-nose
   python-netaddr
   python-simplejson
   createrepo
   python-urlgrabber
   po-debconf
   debhelper}.each do |pkg|
  package pkg do
    action :install
  end
end

directory source_code_root do
  owner build_user
  group build_group
  not_if { ::File.exist?(cobbler_target_filepath) }
end

git cobbler_code_location do
  user build_user
  repository node['cobbler']['repo']['url']
  revision node['cobbler']['repo']['tag']
  action :sync
  not_if { ::File.exist?(cobbler_target_filepath) }
end

#if node[:platform_family] == "rhel"
#  bash 'compile cobbler' do
#    user owner
#    group group
#    code %Q{make rpms &&
#            cp cobbler-*.x86_64.rpm #{cobbler_target_filepath}
#    }
#    cwd cobbler_code_location
#    action :nothing
#  end
#else if node[:platform_family] == "debian"
  bash 'compile cobbler' do
    user build_user
    group build_group
    code %Q{make sdist &&
            dpkg-buildpackage -b -uc &&
            rm ../cobbler_*.changes
    }
    cwd cobbler_code_location
    environment 'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
    not_if { ::File.exist?(cobbler_target_filepath) }
  end

  bash 'move cobbler deb into place' do
    code "cp #{source_code_root}/cobbler_*.deb #{cobbler_target_filepath}"
    not_if { ::File.exist?(cobbler_target_filepath) }
  end

bash "cleanup" do
   code "rm -rf #{cobbler_code_location}"
   only_if node['cobbler']['clean_up_build']
end
