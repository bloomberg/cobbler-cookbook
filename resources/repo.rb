# Base Resource

# Actions that we support.  Must be stated in our provider action :create do.
actions :create, :delete

# Our default action, can be anything.
default_action :create if defined?(default_action)

# Name Space, this is what is passed in "<name>".
attribute :base_name, name_attribute: true, kind_of: String, required: true, default: nil
attribute :owners, kind_of: Array, required: true, default: ['admin']
# Architecture must be one of i386,x86_64,ia64,ppc,ppc64,ppc64le,s390,arm,noarch,src
attribute :architecture, kind_of: String, required: true, default: 'x86_64'
# Must be one of rsync, yum, apt, rhn, wget
attribute :breed, kind_of: String, required: true, default: 'yum'
attribute :mirror_url, kind_of: String, required: true, default: nil

attribute :comment, kind_of: String, required: false, default: nil
attribute :keep_updated, kind_of: [TrueClass, FalseClass], required: false, default: false
attribute :rpm_list, kind_of: Array, required: false, default: nil
attribute :proxy_url, kind_of: String, required: false, default: nil
attribute :apt_components, kind_of: Array, required: false, default: nil
attribute :apt_dist_names, kind_of: Array, required: false, default: nil
attribute :createrepo_flags, kind_of: String, required: false, default: nil
attribute :env_variables, kind_of: Array, required: false, default: nil
attribute :mirror_locally, kind_of: [TrueClass, FalseClass], required: false, default: false
attribute :priority, kind_of: String, required: false, default: '99'
attribute :yum_options, kind_of: String, required: false, default: nil
attribute :clobber, kind_of: [TrueClass, FalseClass], required: false, default: false

# This is a standard ruby accessor, use this to set flags for current state.
attr_accessor :exists
