#
# Cookbook Name:: cobblerd
# Resource:: image
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
actions :add, :remove
default_action :add

attribute :name, kind_of: String, name_attribute: true
attribute :source, kind_of: String, default: nil
attribute :checksum, kind_of: String, default: nil
