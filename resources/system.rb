# Base Resource

# Actions that we support.  Must be stated in our provider action :create do.
actions :create, :delete

# Our default action, can be anything.
default_action :create if defined?(default_action)

# Name Space, this is what is passed in "<name>".
attribute :base_name, name_attribute: true, kind_of: String, required: true, default: nil
attribute :uid, kind_of: String, required: false, default: nil
attribute :owners, kind_of: Array, required: true, default: ['admin']
attribute :profile, kind_of: String, required: false, default: nil
attribute :image, kind_of: String, required: false, default: nil
attribute :status, kind_of: String, required: false, default: nil
attribute :kickstart_options, kind_of: String, required: false, default: nil
attribute :kickstart_options_post, kind_of: String, required: false, default: nil
attribute :ksmeta, kind_of: String, required: false, default: nil
attribute :enable_gpxe, kind_of: String, required: false, default: nil
attribute :proxy, kind_of: String, required: false, default: nil
attribute :netboot_enabled, kind_of: String, required: false, default: nil
attribute :kickstart, kind_of: String, required: false, default: nil
attribute :comment, kind_of: String, required: false, default: nil
attribute :depth, kind_of: String, required: false, default: nil
attribute :server, kind_of: String, required: false, default: nil
attribute :disk_path, kind_of: String, required: false, default: nil
attribute :virtualization_type, kind_of: String, required: false, default: nil
attribute :cpus, kind_of: String, required: false, default: nil
attribute :disk_size, kind_of: String, required: false, default: nil
attribute :disk_driver_type, kind_of: String, required: false, default: nil
attribute :ram, kind_of: Integer, required: false, default: nil
attribute :bridge, kind_of: String, required: false, default: nil
attribute :auto_boot, kind_of: String, required: false, default: nil
attribute :pxe_boot, kind_of: String, required: false, default: nil
attribute :ctime, kind_of: String, required: false, default: nil
attribute :mtime, kind_of: String, required: false, default: nil
attribute :power_type, kind_of: String, required: false, default: nil
attribute :power_address, kind_of: String, required: false, default: nil
attribute :power_user, kind_of: String, required: false, default: nil
attribute :power_pass, kind_of: String, required: false, default: nil
attribute :power_id, kind_of: String, required: false, default: nil
attribute :hostname, kind_of: String, required: false, default: nil
attribute :gateway, kind_of: String, required: false, default: nil
attribute :name_servers, kind_of: String, required: false, default: nil
attribute :name_servers_search_path, kind_of: String, required: false, default: nil
attribute :ipv6_default_device, kind_of: String, required: false, default: nil
attribute :ipv6_autoconfiguration, kind_of: String, required: false, default: nil
attribute :mac_address, kind_of: String, required: false, default: nil
attribute :connected_mode, kind_of: String, required: false, default: nil
attribute :mtu, kind_of: String, required: false, default: nil
attribute :ip_address, kind_of: String, required: false, default: nil
attribute :interface_type, kind_of: String, required: false, default: nil
attribute :bonding, kind_of: String, required: false, default: nil
attribute :interface_master, kind_of: String, required: false, default: nil
attribute :bonding_master, kind_of: String, required: false, default: nil
attribute :bonding_opts, kind_of: String, required: false, default: nil
attribute :bridge_opts, kind_of: String, required: false, default: nil
attribute :management, kind_of: String, required: false, default: nil
attribute :static, kind_of: String, required: false, default: nil
attribute :netmask, kind_of: String, required: false, default: nil
attribute :subnet, kind_of: String, required: false, default: nil
attribute :if_gateway, kind_of: String, required: false, default: nil
attribute :dhcp_tag, kind_of: String, required: false, default: nil
attribute :dns_name, kind_of: String, required: false, default: nil
attribute :static_routes, kind_of: String, required: false, default: nil
attribute :ipv6_address, kind_of: String, required: false, default: nil
attribute :ipv6_prefix, kind_of: String, required: false, default: nil
attribute :ipv6_secondaries, kind_of: String, required: false, default: nil
attribute :ipv6_mtu, kind_of: String, required: false, default: nil
attribute :ipv6_static_routes, kind_of: String, required: false, default: nil
attribute :ipv6_default_gateway, kind_of: String, required: false, default: nil
attribute :mgmt_classes, kind_of: String, required: false, default: nil
attribute :mgmt_parameters, kind_of: String, required: false, default: nil
attribute :boot_files, kind_of: String, required: false, default: nil
attribute :fetchable_files, kind_of: String, required: false, default: nil
attribute :template_files, kind_of: String, required: false, default: nil
attribute :redhat_management_key, kind_of: String, required: false, default: nil
attribute :redhat_management_server, kind_of: String, required: false, default: nil
attribute :template_remote_kickstarts, kind_of: String, required: false, default: nil
attribute :repos_enabled, kind_of: String, required: false, default: nil
attribute :ldap_enabled, kind_of: String, required: false, default: nil
attribute :ldap_type, kind_of: String, required: false, default: nil
attribute :monit_enabled, kind_of: String, required: false, default: nil
attribute :cnames, kind_of: String, required: false, default: nil
attribute :interface, kind_of: String, required: false, default: nil
attribute :delete_interface, kind_of: String, required: false, default: nil
attribute :rename_interface, kind_of: String, required: false, default: nil
attribute :clobber, kind_of: [TrueClass, FalseClass], required: false, default: false
attribute :in_place, kind_of: [TrueClass, FalseClass], required: false, default: false

# This is a standard ruby accessor, use this to set flags for current state.
attr_accessor :exists
