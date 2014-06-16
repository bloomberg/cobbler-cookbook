#
# Cookbook Name:: cobblerd
# Resource:: image
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
actions :import
default_action :import

attribute :name, kind_of: String, name_attribute: true
attribute :arch, kind_of: String
attribute :breed, kind_of: String
attribute :source, kind_of: String
attribute :checksum, kind_of: String
attribute :os_version, kind_of: String
attribute :kickstart, kind_of: String
