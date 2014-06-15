#
# Cookbook Name:: cobblerd
# Resource:: system
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
action :add, :remove
default_action :add

attribute :name, kind_of: String, name_attribute: true
attribute :mac_address, kind_of: String
attribute :image, kind_of: String
