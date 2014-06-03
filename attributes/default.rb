#
# Cookbook Name:: cobbler
# Attribute:: default
#
# Copyright (C) 2013, 2014 Bloomberg Finance L.P.
#

default['389ds']['user'] = 'admin'
default['389ds']['password'] = 'password'
default['389ds']['rootdn']['user'] = 'cn=Directory Manager'
default['389ds']['rootdn']['password'] = 'password'
default['389ds']['replication']['user'] = 'cn=Replication Manager'
default['389ds']['replication']['password'] = 'password'
