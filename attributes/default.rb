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
