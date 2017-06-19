# Base Resource

# Actions that we support.  Must be stated in our provider action :create do.
actions :create, :delete

# Our default action, can be anything.
default_action :create if defined?(default_action)

# WARNING: some options are not idempotent:
# source - will not update if changed after creation
# target - will not update if changed after creation
# os_version - will not update if changed after creation
# os_arch - will not update if changed after creation
# os_breed - will not update if changed after creation
# initrd - will not update if changed after creation w/o checksum
# kernel - will not update if changed after creation w/o checksum
attribute :base_name, name_attribute: true, kind_of: String, required: true, default: nil
attribute :source, kind_of: String, required: true
attribute :initrd, kind_of: String, default: nil
attribute :initrd_checksum, kind_of: String, default: nil
attribute :kernel, kind_of: String, default: nil
attribute :kernel_checksum, kind_of: String, default: nil
attribute :target, kind_of: String, default: nil
attribute :checksum, kind_of: String
attribute :os_version, kind_of: String
attribute :os_arch, kind_of: String, default: 'x86_64'
attribute :os_breed, kind_of: String, required: true
