#
# Cookbook Name:: cobblerd
# Recipe:: syslinux_source
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#

build_user = 'nobody'
build_group = 'nogroup'

source_code_root = "#{Chef::Config[:file_cache_path]}/syslinux_build"

syslinux_code_location = "#{source_code_root}/syslinux"
syslinux_artifacts = %w{efi32/com32/lua/src/syslinux.elf
                        bios/dos/syslinux.elf
                        bios/com32/lua/src/syslinux.elf
                        efi64/com32/lua/src/syslinux.elf}
syslinux_target_filepaths = syslinux_artifacts.map{ |m| "#{syslinux_code_location}/#{m}" }

# syslinux build dependencies
uuid_pkg = "libuuid-devel"if node[:platform_family] == "rhel"
uuid_pkg = "uuid-dev"if node[:platform_family] == "debian"
%W{make
   git
   gcc
   debhelper
   po-debconf
   createrepo
   libc6-dbg
   libc6-dev
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
  not_if { ::File.exist?(source_code_root) }
end

git syslinux_code_location do
  user build_user
  repository node[:cobbler][:syslinux][:repo][:url]
  revision node[:cobbler][:syslinux][:repo][:revision]
  action :sync
  notifies :run, 'bash[compile syslinux]', :immediately
  not_if { syslinux_target_filepaths.map { |p| ::File.exist?(p) }.all? }
end

bash 'compile syslinux' do
  user build_user
  group build_group
  code %Q{make all && pushd gnu-efi/gnu-efi-3.0 && dpkg-buildpackage -b -uc}
  cwd syslinux_code_location
  action :nothing
end

