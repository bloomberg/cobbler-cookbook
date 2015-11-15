#
# Cookbook Name:: cobblerd
# Recipe:: syslinux_package
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#

syslinux_tarball = "#{Chef::Config[:file_cache_path]}/syslinux.tar.gz"

remote_file syslinux_tarball do
  source node['cobbler']['syslinux']['binary']['url']
  action :create
  checksum node[:cobbler][:syslinux][:binary][:signature]
  not_if { ::File.exists?('/var/lib/cobbler/loaders') }
end

# files to copy in /var/lib/tftpboot/
syslinux_files = {
"bios" => %w{
             syslinux-6.03/bios/core/pxelinux.0
             syslinux-6.03/bios/com32/elflink/ldlinux/ldlinux.c32
             syslinux-6.03/bios/com32/lib/libcom32.c32
             syslinux-6.03/bios/com32/libutil/libutil.c32
             syslinux-6.03/bios/com32/menu/vesamenu.c32
             syslinux-6.03/bios/com32/modules/pxechn.c32
            },
"efi64" => %w{
              syslinux-6.03/efi64/efi/syslinux.efi
              syslinux-6.03/efi64/com32/elflink/ldlinux/ldlinux.e64
              syslinux-6.03/efi64/com32/lib/libcom32.c32
              syslinux-6.03/efi64/com32/libutil/libutil.c32
              syslinux-6.03/efi64/com32/menu/vesamenu.c32
              syslinux-6.03/efi64/com32/modules/pxechn.c32
             }
}

syslinux_files.keys.each do |dirname|
  directory "/var/lib/tftpboot/#{dirname}" do
    action :create
    recursive true
  end

  syslinux_files[dirname].each do |fname|
    bash "extract_syslinux_#{dirname}_#{fname}" do
      code "tar -xzf #{syslinux_tarball} -C /var/lib/tftpboot/#{dirname} --strip-components #{fname.gsub(/[^\/]/, '').length} #{fname}"
      action :run
      not_if { ::File.exists?("/var/lib/tftpboot/#{dirname}/#{fname}") }
    end
  end
end

# XXX is this necessary?
#remote_file signed_grub do
#  source node['cobbler']['grub']['uefi_signed']['url']
#  action :create
#  not_if { ::File.exists?('/var/lib/cobbler/loaders') }
#end

