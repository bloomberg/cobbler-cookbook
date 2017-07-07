actions :create, :delete

default_action :create

attribute :base_name, name_attribute: true, kind_of: String, required: true, default: nil
attribute :distro, kind_of: String, required: false, default: nil

attribute :comment, kind_of: String, required: false, default: nil
attribute :kickstart, kind_of: String, required: false, default: nil
attribute :kickstart_meta, kind_of: Hash, required: false, default: {}
attribute :boot_files, kind_of: Hash, required: false, default: nil
attribute :dhcp_tag, kind_of: String, required: false, default: nil
attribute :enable_gpxe, kind_of: String, required: false, default: nil
attribute :enable_pxe_menu, kind_of: String, required: false, default: nil
attribute :fetchable_files, kind_of: Hash, required: false, default: nil
attribute :kernel_options, kind_of: Hash, default: { interface: 'auto' }
attribute :kernel_options_postinstall, kind_of: Hash, default: {}
attribute :mgmt_classes, kind_of: Hash, required: false, default: nil
attribute :mgmt_parameters, kind_of: String, required: false, default: nil
attribute :name_servers, kind_of: String, required: false, default: nil
attribute :name_servers_search_path, kind_of: String, required: false, default: nil
attribute :owners, kind_of: Array, required: false, default: nil
attribute :parent_profile, kind_of: String, required: false, default: nil
attribute :internal_proxy, kind_of: String, required: false, default: nil
attribute :redhat_management_key, kind_of: String, required: false, default: nil
attribute :redhat_management_server, kind_of: String, required: false, default: nil
attribute :repos, kind_of: Array, required: false, default: nil
attribute :server_override, kind_of: String, required: false, default: nil
attribute :template_files, kind_of: String, required: false, default: nil
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
