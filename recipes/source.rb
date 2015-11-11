#
# Cookbook Name:: cobblerd
# Recipe:: source
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

syslinux_code_location = "#{source_code_root}/syslinux"
syslinux_artifacts = %w{efi32/com32/lua/src/syslinux.elf
                        bios/dos/syslinux.elf
                        bios/com32/lua/src/syslinux.elf
                        efi64/com32/lua/src/syslinux.elf}
syslinux_target_filepaths = syslinux_artifacts.map{ |m| "#{syslinux_code_location}/#{m}" }

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

# syslinux build dependencies
uuid_pkg = "libuuid-devel"if node[:platform_family] == "rhel"
uuid_pkg = "uuid-dev"if node[:platform_family] == "debian"
%W{libc6-dev:i386
   libc6-dev:amd64
   libc6-dev-amd64
   gcc
   gcc
   gcc
   gcc
   build-essential
   debhelper
   gcc-multilib
   dpkg-dev
   nasm
   #{uuid_pkg}}.each do |pkg|
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

git syslinux_code_location do
  user build_user
  repository node[:cobbler][:syslinux][:repo][:url]
  revision node[:cobbler][:syslinux][:repo][:revision]
  action :sync
  notifies :run, 'bash[compile syslinux]', :immediately
  not_if { syslinux_target_filepaths.map { |p| ::File.exist?(p) }.all? }
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
            rm ../cobbler_*.changes &&
    }
    cwd cobbler_code_location
    environment 'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
    action :nothing
  end

  bash 'move deb into place' do
    code "mv #{cobbler_code_location}/cobbler_*_all.deb #{cobbler_target_filepath}"
    action :run
    only_if { ::Dir.glob("#{cobbler_code_location}/cobbler_*_all.deb").length > 0 }
  end

  # install cobbler
  dpkg_package 'cobbler' do
    source cobbler_target_filepath
  end
#end

bash "cleanup" do
   code "rm -rf #{cobbler_code_location}"
   only_if { ::File.exist?(cobbler_code_location) }
end

bash 'compile syslinux' do
  user build_user
  group build_group
  code %Q{make all && pushd gnu-efi/gnu-efi-3.0 && dpkg-buildpackage -b -uc}
  cwd syslinux_code_location
  action :nothing
end

