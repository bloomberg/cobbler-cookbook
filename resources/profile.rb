#
# Cookbook Name:: cobblerd
# Resource:: profile
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
actions :add, :remove
default_action :add

attribute :name, kind_of: String, name_attribute: true
attribute :distro, kind_of: String
attribute :kickstart, kind_of: String
