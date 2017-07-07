# Base Resource

# Actions that we support.  Must be stated in our provider action :create do.
actions :create, :import, :delete

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
attribute :architecture, kind_of: String, required: true, default: 'x86_64'
attribute :comment, kind_of: String, required: false, default: nil
attribute :owners, kind_of: Array, required: true, default: ['admin']
attribute :ctime, kind_of: String, required: false, default: nil
attribute :mtime, kind_of: String, required: false, default: nil

# This is the source for the remote image file that will be downloaded if a value is specified.
attribute :source, kind_of: String, required: false, default: nil
attribute :checksum, kind_of: String, required: false, default: nil
attribute :kickstart, kind_of: String, required: false, default: nil
# This corresopnds to the --file input and can be a local file or an NFS mount
attribute :target, kind_of: String, required: false, default: nil
# Must be one of iso,direct,memdisk,virt-image
attribute :image_type, kind_of: String, required: false, default: 'iso'
attribute :os_version, kind_of: String, required: false, default: nil
attribute :os_breed, kind_of: String, required: false, default: nil
# Number of NICs, corresponds to the --network-count input
attribute :network_count, kind_of: String, required: false, default: '1'
attribute :auto_boot, kind_of: [TrueClass, FalseClass], required: false, default: nil
attribute :bridge, kind_of: String, required: false, default: nil
attribute :cpus, kind_of: String, required: false, default: nil
attribute :disk_driver_type, kind_of: String, required: false, default: nil
attribute :disk_size, kind_of: String, required: false, default: nil
attribute :disk_path, kind_of: String, required: false, default: nil
attribute :ram, kind_of: String, required: false, default: nil
attribute :virtualization_type, kind_of: String, required: false, default: nil

# This is a standard ruby accessor, use this to set flags for current state.
attr_accessor :exists
