#
# Cookbook Name:: cobblerd
# Recipe:: cobbler_source
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#

build_user = 'nobody'
build_group = 'nogroup'

source_code_root = "#{Chef::Config[:file_cache_path]}/cobbler_build"

cobbler_code_location = "#{source_code_root}/cobbler"
cobbler_target_filename = 'cobbler.rpm' if node[:platform_family] == "rhel"
cobbler_target_filename = 'cobbler.deb' if node[:platform_family] == "debian"
cobbler_target_filepath = "#{node[:cobbler][:bin_dir]}/#{cobbler_target_filename}"

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
  repository node[:cobbler][:repo][:url]
  revision node[:cobbler][:repo][:revision]
  action :sync
  notifies :run, 'bash[ensure cobbler on correct tag]', :immediately
  not_if { ::File.exist?(cobbler_target_filepath) }
end

bash 'ensure cobbler on correct tag' do
  user build_user
  group build_group
  cwd cobbler_code_location
  code "git checkout -b #{node[:cobbler][:repo][:revision]}"
  action :nothing
  notifies :run, 'bash[compile cobbler]', :immediately
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
    action :nothing
  end

  bash 'move cobbler deb into place' do
    code "mv #{source_code_root}/cobbler_*.deb #{cobbler_target_filepath}"
    action :run
    only_if { ::Dir.glob("#{source_code_root}/cobbler_*.deb").length > 0 }
  end

  # install cobbler
  bash 'install cobbler' do
    code "dpkg -i #{cobbler_target_filepath} || apt-get install -yf && dpkg -l cobbler"
    not_if "dpkg -l cobbler"
  end
 
  node.default['cobbler']['service_name'] = "cobblerd"
#end

bash "cleanup" do
   code "rm -rf #{cobbler_code_location}"
   only_if { ::File.exist?(cobbler_code_location) }
end

include_recipe 'cobblerd::web'
