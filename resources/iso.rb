# Base Resource

# Actions that we support.  Must be stated in our provider action :create do.
actions :import, :delete

# Our default action, can be anything.
default_action :import if defined?(default_action)

attribute :base_name, name_attribute: true, kind_of: String, required: true, default: nil
attribute :source, kind_of: String, required: true, default: nil
attribute :target, kind_of: String, required: false, default: nil
attribute :checksum, kind_of: String, required: false, default: nil

# This is a standard ruby accessor, use this to set flags for current state.
attr_accessor :exists
