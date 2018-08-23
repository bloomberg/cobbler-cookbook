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
build_requirements = %w{checkinstall
                        git
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
                        debhelper}

build_requirements.each do |pkg|
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

bash 'compile cobbler' do
  user build_user
  group build_group
  code('make sdist && ' \
       'rm -f ./cobbler.spec && ' \
       'checkinstall -D -y ' \
       '  --install=yes ' \
       '  --fstrans=yes '\
       "  --pkgversion=#{node[:cobbler][:repo][:tag].gsub(/^v/,'')} " \
       '  --pkgrelease=1' \
       "  --requires #{build_requirements.join(',')}" \
       '  && ' \
       'rm -f ../cobbler_*.changes')
  cwd cobbler_code_location
  environment 'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
  not_if { ::File.exist?(cobbler_target_filepath) }
end

bash 'move cobbler deb into place' do
  code("cp #{cobbler_code_location}/cobbler_*.deb #{cobbler_target_filepath}")
  not_if { ::File.exist?(cobbler_target_filepath) }
end

bash "cleanup" do
   code "rm -rf #{cobbler_code_location}"
   only_if node['cobbler']['clean_up_build']
end
