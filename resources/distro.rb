# Base Resource

# Actions that we support.  Must be stated in our provider action :create do.
actions :create, :delete

# Our default action, can be anything.
default_action :create if defined?(default_action)

# Name Space, this is what is passed in "<name>".
attribute :base_name, name_attribute: true, kind_of: String, required: true, default: nil
attribute :owners, kind_of: Array, required: true, default: ['admin']
attribute :kernel, kind_of: String, required: true, default: nil
attribute :initrd, kind_of: String, required: true, default: nil
# Valid options i386,x86_64,ia64,ppc,ppc64,ppc64le,s390,arm
attribute :architecture, kind_of: String, required: true, default: nil
# Valid options
attribute :os_breed, kind_of: String, required: true, default: nil
# Valid options
attribute :os_version, kind_of: String, required: true, default: nil

attribute :comment, kind_of: String, required: false, default: nil
attribute :ctime, kind_of: String, required: false, default: nil
attribute :mtime, kind_of: String, required: false, default: nil
attribute :uid, kind_of: String, required: false, default: nil
attribute :kernel_options, kind_of: Hash, required: false, default: nil
attribute :kernel_options_postinstall, kind_of: Hash, required: false, default: nil
attribute :kickstart_meta, kind_of: Hash, required: false, default: nil
attribute :source_repos, kind_of: Array, required: false, default: nil
attribute :depth, kind_of: String, required: false, default: nil
attribute :tree_build_time, kind_of: String, required: false, default: nil
attribute :mgmt_classes, kind_of: String, required: false, default: nil
attribute :boot_files, kind_of: Array, required: false, default: nil
attribute :fetchable_files, kind_of: Hash, required: false, default: nil
attribute :template_files, kind_of: Hash, required: false, default: nil
attribute :redhat_management_key, kind_of: String, required: false, default: nil
attribute :redhat_management_server, kind_of: String, required: false, default: nil
attribute :clobber, kind_of: [TrueClass, FalseClass], required: false, default: false
attribute :in_place, kind_of: [TrueClass, FalseClass], required: false, default: false

# This is a standard ruby accessor, use this to set flags for current state.
attr_accessor :exists
