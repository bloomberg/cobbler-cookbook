#
# Cookbook Name:: cobblerd
# Attribute:: default
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#

default[:cobblerd][:web_username] = 'cobbler'
default[:cobblerd][:web_password] = 'cobbler'

default[:cobblerd][:ks][:username] = 'cloud'

default[:cobblerd][:resource_storage] = '/var/local/cobbler/images/'

# Syslinux git repo and revision
default[:cobbler][:syslinux][:repo][:url] = 'http://repo.or.cz/syslinux.git'
default[:cobbler][:syslinux][:repo][:revision] = 'syslinux-6.03'
default[:cobbler][:syslinux][:binary][:url] = 'https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz'
default[:cobbler][:syslinux][:binary][:signature] = '250b9bd90945d361596a7a69943d0bdc5fc0c0917aa562609f8d3058a2c36b3a'

# in some cases the Chef file cache is not writeable by nobody so allow overriding
default['cobbler']['source']['dir'] = "#{Chef::Config[:file_cache_path]}/cobbler_build"

# EFI signed GRUB
default['cobbler']['grub']['uefi_signed']['url'] = 'http://archive.ubuntu.com/ubuntu/dists/trusty/main/uefi/grub2-amd64/current/grubnetx64.efi.signed'

# Cobbler git repo and revision
default[:cobbler][:repo][:url] = 'https://github.com/cobbler/cobbler'
# revision points to v2.6.10
default[:cobbler][:repo][:revision] = '5bffb9e73faa5c48e167e86f04d4687576810e4e'

# Cobbler build location
default[:cobbler][:bin_dir] = "#{Chef::Config[:file_cache_path]}"

# $ echo 'cobbler' | mkpasswd -S LQTvGQ11AIG0k -s -m sha-512
default[:cobblerd][:ks][:root_password] = '$6$LQTvGQ11AIG0k$TOSqMnXrQ9Y.3AP6KwRnMitmRaIeteoDKlxVbJgxXB07bK8HdzthHps8gjbIn0iYbTI1BpOVIUtqks6Ed06E7/'
default[:cobblerd][:ks][:user_password] = '$6$LQTvGQ11AIG0k$TOSqMnXrQ9Y.3AP6KwRnMitmRaIeteoDKlxVbJgxXB07bK8HdzthHps8gjbIn0iYbTI1BpOVIUtqks6Ed06E7/'

# replaced barewords found via grep -h 'name.replace' /usr/lib/python2.7/dist-packages/cobbler/modules/*|sort -u
default[:cobblerd][:distro][:reserved_words][:bare_words] = ["--", "-amd64", "-boot", "chrp", "-i386",
     "-images", "-install", "-isolinux", "ks_mirror-", "-loader", "-netboot", "-os",
     "-pxeboot", "srv-www-cobbler-", "-tree", "-ubuntu-installer", "var-www-cobbler-"]

# reserved arches and separators found via grep -B2 -h 'name.replace("%s%s"' /usr/lib/python2.7/dist-packages/cobbler/modules/*
default[:cobblerd][:distro][:reserved_words][:arch] = ["i386" , "x86_64" , "ia64" , "ppc64",
     "ppc32", "ppc", "x86" , "s390x", "s390" , "386" , "amd", "arm"]
default[:cobblerd][:distro][:reserved_words][:separators] = ["-", "_", "."]
