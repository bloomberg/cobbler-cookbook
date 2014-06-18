#
# Cookbook Name:: cobblerd
# Attribute:: default
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#

default[:cobbler][:ks][:username] = 'cloud'

# $ echo 'cobbler' | mkpasswd -S LQTvGQ11AIG0k -s -m sha-512
default[:cobbler][:ks][:root_password] = '$6$LQTvGQ11AIG0k$TOSqMnXrQ9Y.3AP6KwRnMitmRaIeteoDKlxVbJgxXB07bK8HdzthHps8gjbIn0iYbTI1BpOVIUtqks6Ed06E7/'
default[:cobbler][:ks][:user_password] = '$6$LQTvGQ11AIG0k$TOSqMnXrQ9Y.3AP6KwRnMitmRaIeteoDKlxVbJgxXB07bK8HdzthHps8gjbIn0iYbTI1BpOVIUtqks6Ed06E7/'
