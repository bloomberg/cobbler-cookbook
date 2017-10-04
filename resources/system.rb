# Base Resource
provides :cobbler_system
resource_name :cobbler_system

# Actions that we support.  Must be stated in our provider action :create do.
actions :create, :delete

# Our default action, can be anything.
default_action :create if defined?(default_action)

# Name Space, this is what is passed in "<name>".
property :name, name_attribute: true, kind_of: String, required: true
property :uid, kind_of: String, required: false, desired_state: false, default: nil
property :owners, kind_of: Array, required: true, desired_state: false, default: ['admin']
property :profile, kind_of: String, required: false, desired_state: false, default: nil
property :image, kind_of: String, required: false, desired_state: false, default: nil
property :status, kind_of: String, required: false, desired_state: false, default: nil
property :kickstart_options, kind_of: String, required: false, desired_state: false, default: nil
property :kickstart_options_post, kind_of: String, required: false, desired_state: false, default: nil
property :ksmeta, kind_of: String, required: false, desired_state: false, default: nil
property :enable_gpxe, kind_of: String, required: false, desired_state: false, default: nil
property :proxy, kind_of: String, required: false, desired_state: false, default: nil
property :netboot_enabled, kind_of: String, required: false, desired_state: false, default: nil
property :kickstart, kind_of: String, required: false, desired_state: false, default: nil
property :comment, kind_of: String, required: false, desired_state: false, default: nil
property :depth, kind_of: String, required: false, desired_state: false, default: nil
property :server, kind_of: String, required: false, desired_state: false, default: nil
property :disk_path, kind_of: String, required: false, desired_state: false, default: nil
property :virtualization_type, kind_of: String, required: false, desired_state: false, default: nil
property :cpus, kind_of: String, required: false, desired_state: false, default: nil
property :disk_size, kind_of: String, required: false, desired_state: false, default: nil
property :disk_driver_type, kind_of: String, required: false, desired_state: false, default: nil
property :ram, kind_of: Integer, required: false, desired_state: false, default: nil
property :bridge, kind_of: String, required: false, desired_state: false, default: nil
property :auto_boot, kind_of: String, required: false, desired_state: false, default: nil
property :pxe_boot, kind_of: String, required: false, desired_state: false, default: nil
property :ctime, kind_of: String, required: false, desired_state: false, default: nil
property :mtime, kind_of: String, required: false, desired_state: false, default: nil
property :power_type, kind_of: String, required: false, desired_state: false, default: nil
property :power_address, kind_of: String, required: false, desired_state: false, default: nil
property :power_user, kind_of: String, required: false, desired_state: false, default: nil
property :power_pass, kind_of: String, required: false, desired_state: false, default: nil
property :power_id, kind_of: String, required: false, desired_state: false, default: nil
property :hostname, kind_of: String, required: false, desired_state: false, default: nil
property :gateway, kind_of: String, required: false, desired_state: false, default: nil
property :name_servers, kind_of: String, required: false, desired_state: false, default: nil
property :name_servers_search_path, kind_of: String, required: false, desired_state: false, default: nil
property :ipv6_default_device, kind_of: String, required: false, desired_state: false, default: nil
property :ipv6_autoconfiguration, kind_of: String, required: false, desired_state: false, default: nil
property :mac_address, kind_of: String, required: false, desired_state: false, default: nil
property :connected_mode, kind_of: String, required: false, desired_state: false, default: nil
property :mtu, kind_of: String, required: false, desired_state: false, default: nil
property :ip_address, kind_of: String, required: false, desired_state: false, default: nil
property :interface_type, kind_of: String, required: false, desired_state: false, default: nil
property :bonding, kind_of: String, required: false, desired_state: false, default: nil
property :interface_master, kind_of: String, required: false, desired_state: false, default: nil
property :bonding_master, kind_of: String, required: false, desired_state: false, default: nil
property :bonding_opts, kind_of: String, required: false, desired_state: false, default: nil
property :bridge_opts, kind_of: String, required: false, desired_state: false, default: nil
property :management, kind_of: String, required: false, desired_state: false, default: nil
property :static, kind_of: String, required: false, desired_state: false, default: nil
property :netmask, kind_of: String, required: false, desired_state: false, default: nil
property :subnet, kind_of: String, required: false, desired_state: false, default: nil
property :if_gateway, kind_of: String, required: false, desired_state: false, default: nil
property :dhcp_tag, kind_of: String, required: false, desired_state: false, default: nil
property :dns_name, kind_of: String, required: false, desired_state: false, default: nil
property :static_routes, kind_of: String, required: false, desired_state: false, default: nil
property :ipv6_address, kind_of: String, required: false, desired_state: false, default: nil
property :ipv6_prefix, kind_of: String, required: false, desired_state: false, default: nil
property :ipv6_secondaries, kind_of: String, required: false, desired_state: false, default: nil
property :ipv6_mtu, kind_of: String, required: false, desired_state: false, default: nil
property :ipv6_static_routes, kind_of: String, required: false, desired_state: false, default: nil
property :ipv6_default_gateway, kind_of: String, required: false, desired_state: false, default: nil
property :mgmt_classes, kind_of: String, required: false, desired_state: false, default: nil
property :mgmt_parameters, kind_of: String, required: false, desired_state: false, default: nil
property :boot_files, kind_of: String, required: false, desired_state: false, default: nil
property :fetchable_files, kind_of: String, required: false, desired_state: false, default: nil
property :template_files, kind_of: String, required: false, desired_state: false, default: nil
property :redhat_management_key, kind_of: String, required: false, desired_state: false, default: nil
property :redhat_management_server, kind_of: String, required: false, desired_state: false, default: nil
property :template_remote_kickstarts, kind_of: String, required: false, desired_state: false, default: nil
property :repos_enabled, kind_of: String, required: false, desired_state: false, default: nil
property :ldap_enabled, kind_of: String, required: false, desired_state: false, default: nil
property :ldap_type, kind_of: String, required: false, desired_state: false, default: nil
property :monit_enabled, kind_of: String, required: false, desired_state: false, default: nil
property :cnames, kind_of: String, required: false, desired_state: false, default: nil
property :interface, kind_of: String, required: false, desired_state: false, default: nil
property :delete_interface, kind_of: String, required: false, desired_state: false, default: nil
property :rename_interface, kind_of: String, required: false, desired_state: false, default: nil
property :clobber, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :clobber, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false

# This is a standard ruby accessor, use this to set flags for current state.
attr_accessor :exists

action :create do
  # TODO: Add check to ensure that the specified profile exists.
  validate_input

  if !exists?
    # Setup command with known required attributes. Since only name is required to delete, that is all we're using.
    system_command = "cobbler system add --name=#{@current_resource.name}"

    # Setup command with known required attributes
    system_command = "#{system_command} --uid='#{new_resource.uid}'" if new_resource.uid
    system_command = "#{system_command} --owners='#{new_resource.owners.join(',')}'"
    system_command = "#{system_command} --profile='#{new_resource.profile}'" if new_resource.profile
    system_command = "#{system_command} --image='#{new_resource.image}'" if new_resource.image
    system_command = "#{system_command} --status='#{new_resource.status}'" if new_resource.status
    system_command = "#{system_command} --kickstart_options='#{new_resource.kickstart_options}'" if new_resource.kickstart_options
    system_command = "#{system_command} --kickstart_options_post='#{new_resource.kickstart_options_post}'" if new_resource.kickstart_options_post
    system_command = "#{system_command} --ksmeta='#{new_resource.ksmeta}'" if new_resource.ksmeta
    system_command = "#{system_command} --enable_gpxe='#{new_resource.enable_gpxe}'" if new_resource.enable_gpxe
    system_command = "#{system_command} --proxy='#{new_resource.proxy}'" if new_resource.proxy
    system_command = "#{system_command} --netboot_enabled='#{new_resource.netboot_enabled}'" if new_resource.netboot_enabled
    system_command = "#{system_command} --kickstart='#{new_resource.kickstart}'" if new_resource.kickstart
    system_command = "#{system_command} --comment='#{new_resource.comment}'" if new_resource.comment
    system_command = "#{system_command} --depth='#{new_resource.depth}'" if new_resource.depth
    system_command = "#{system_command} --server='#{new_resource.server}'" if new_resource.server
    system_command = "#{system_command} --disk_path='#{new_resource.disk_path}'" if new_resource.disk_path
    system_command = "#{system_command} --virtualization_type='#{new_resource.virtualization_type}'" if new_resource.virtualization_type
    system_command = "#{system_command} --cpus='#{new_resource.cpus}'" if new_resource.cpus
    system_command = "#{system_command} --disk_size='#{new_resource.disk_size}'" if new_resource.disk_size
    system_command = "#{system_command} --disk_driver_type='#{new_resource.disk_driver_type}'" if new_resource.disk_driver_type
    system_command = "#{system_command} --ram='#{new_resource.ram}'" if new_resource.ram
    system_command = "#{system_command} --bridge='#{new_resource.bridge}'" if new_resource.bridge
    system_command = "#{system_command} --auto_boot='#{new_resource.auto_boot}'" if new_resource.auto_boot
    system_command = "#{system_command} --pxe_boot='#{new_resource.pxe_boot}'" if new_resource.pxe_boot
    system_command = "#{system_command} --ctime='#{new_resource.ctime}'" if new_resource.ctime
    system_command = "#{system_command} --mtime='#{new_resource.mtime}'" if new_resource.mtime
    system_command = "#{system_command} --power_type='#{new_resource.power_type}'" if new_resource.power_type
    system_command = "#{system_command} --power_address='#{new_resource.power_address}'" if new_resource.power_address
    system_command = "#{system_command} --power_user='#{new_resource.power_user}'" if new_resource.power_user
    system_command = "#{system_command} --power_pass='#{new_resource.power_pass}'" if new_resource.power_pass
    system_command = "#{system_command} --power_id='#{new_resource.power_id}'" if new_resource.power_id
    system_command = "#{system_command} --hostname='#{new_resource.hostname}'" if new_resource.hostname
    system_command = "#{system_command} --gateway='#{new_resource.gateway}'" if new_resource.gateway
    system_command = "#{system_command} --name_servers='#{new_resource.name_servers}'" if new_resource.name_servers
    system_command = "#{system_command} --name_servers_search_path='#{new_resource.name_servers_search_path}'" if new_resource.name_servers_search_path
    system_command = "#{system_command} --ipv6_default_device='#{new_resource.ipv6_default_device}'" if new_resource.ipv6_default_device
    system_command = "#{system_command} --ipv6_autoconfiguration='#{new_resource.ipv6_autoconfiguration}'" if new_resource.ipv6_autoconfiguration
    system_command = "#{system_command} --mac_address='#{new_resource.mac_address}'" if new_resource.mac_address
    system_command = "#{system_command} --connected_mode='#{new_resource.connected_mode}'" if new_resource.connected_mode
    system_command = "#{system_command} --mtu='#{new_resource.mtu}'" if new_resource.mtu
    system_command = "#{system_command} --ip_address='#{new_resource.ip_address}'" if new_resource.ip_address
    system_command = "#{system_command} --interface_type='#{new_resource.interface_type}'" if new_resource.interface_type
    system_command = "#{system_command} --bonding='#{new_resource.bonding}'" if new_resource.bonding
    system_command = "#{system_command} --interface_master='#{new_resource.interface_master}'" if new_resource.interface_master
    system_command = "#{system_command} --bonding_master='#{new_resource.bonding_master}'" if new_resource.bonding_master
    system_command = "#{system_command} --bonding_opts='#{new_resource.bonding_opts}'" if new_resource.bonding_opts
    system_command = "#{system_command} --bridge_opts='#{new_resource.bridge_opts}'" if new_resource.bridge_opts
    system_command = "#{system_command} --management='#{new_resource.management}'" if new_resource.management
    system_command = "#{system_command} --static='#{new_resource.static}'" if new_resource.static
    system_command = "#{system_command} --netmask='#{new_resource.netmask}'" if new_resource.netmask
    system_command = "#{system_command} --subnet='#{new_resource.subnet}'" if new_resource.subnet
    system_command = "#{system_command} --if_gateway='#{new_resource.if_gateway}'" if new_resource.if_gateway
    system_command = "#{system_command} --dhcp_tag='#{new_resource.dhcp_tag}'" if new_resource.dhcp_tag
    system_command = "#{system_command} --dns_name='#{new_resource.dns_name}'" if new_resource.dns_name
    system_command = "#{system_command} --static_routes='#{new_resource.static_routes}'" if new_resource.static_routes
    system_command = "#{system_command} --ipv6_address='#{new_resource.ipv6_address}'" if new_resource.ipv6_address
    system_command = "#{system_command} --ipv6_prefix='#{new_resource.ipv6_prefix}'" if new_resource.ipv6_prefix
    system_command = "#{system_command} --ipv6_secondaries='#{new_resource.ipv6_secondaries}'" if new_resource.ipv6_secondaries
    system_command = "#{system_command} --ipv6_mtu='#{new_resource.ipv6_mtu}'" if new_resource.ipv6_mtu
    system_command = "#{system_command} --ipv6_static_routes='#{new_resource.ipv6_static_routes}'" if new_resource.ipv6_static_routes
    system_command = "#{system_command} --ipv6_default_gateway='#{new_resource.ipv6_default_gateway}'" if new_resource.ipv6_default_gateway
    system_command = "#{system_command} --mgmt_classes='#{new_resource.mgmt_classes}'" if new_resource.mgmt_classes
    system_command = "#{system_command} --mgmt_parameters='#{new_resource.mgmt_parameters}'" if new_resource.mgmt_parameters
    system_command = "#{system_command} --boot_files='#{new_resource.boot_files}'" if new_resource.boot_files
    system_command = "#{system_command} --fetchable_files='#{new_resource.fetchable_files}'" if new_resource.fetchable_files
    system_command = "#{system_command} --template_files='#{new_resource.template_files}'" if new_resource.template_files
    system_command = "#{system_command} --redhat_management_key='#{new_resource.redhat_management_key}'" if new_resource.redhat_management_key
    system_command = "#{system_command} --redhat_management_server='#{new_resource.redhat_management_server}'" if new_resource.redhat_management_server
    system_command = "#{system_command} --template_remote_kickstarts='#{new_resource.template_remote_kickstarts}'" if new_resource.template_remote_kickstarts
    system_command = "#{system_command} --repos_enabled='#{new_resource.repos_enabled}'" if new_resource.repos_enabled
    system_command = "#{system_command} --ldap_enabled='#{new_resource.ldap_enabled}'" if new_resource.ldap_enabled
    system_command = "#{system_command} --ldap_type='#{new_resource.ldap_type}'" if new_resource.ldap_type
    system_command = "#{system_command} --monit_enabled='#{new_resource.monit_enabled}'" if new_resource.monit_enabled
    system_command = "#{system_command} --cnames='#{new_resource.cnames}'" if new_resource.cnames
    system_command = "#{system_command} --interface='#{new_resource.interface}'" if new_resource.interface
    system_command = "#{system_command} --delete_interface='#{new_resource.delete_interface}'" if new_resource.delete_interface
    system_command = "#{system_command} --rename_interface='#{new_resource.rename_interface}'" if new_resource.rename_interface
    system_command = "#{system_command} --clobber='#{new_resource.clobber}'" if new_resource.clobber
    system_command = "#{system_command} --in_place='#{new_resource.in_place}'" if new_resource.in_place

    bash "#{new_resource.name}-cobbler-system-create" do
      code command
      notifies :run, 'bash[cobbler-sync]', :delayed
    end
  end
end

action :delete do

end


load_current_value do
  if exists?
    data = load_cobbler_system

    # TODO: Use the 'send' feature / function to programatically (and dynamically) do this.
    name field_value(data, 'name')
    uid field_value(data, 'uid')
    owners field_value(data, 'owners')
    profile field_value(data, 'profile')
    image field_value(data, 'image')
    status field_value(data, 'status')
    kickstart_options field_value(data, 'kickstart_options')
    kickstart_options_post field_value(data, 'kickstart_options_post')
    ksmeta field_value(data, 'ksmeta')
    enable_gpxe field_value(data, 'enable_gpxe')
    proxy field_value(data, 'proxy')
    netboot_enabled field_value(data, 'netboot_enabled')
    kickstart field_value(data, 'kickstart')
    comment field_value(data, 'comment')
    depth field_value(data, 'depth')
    server field_value(data, 'server')
    disk_path field_value(data, 'disk_path')
    virtualization_type field_value(data, 'virtualization_type')
    cpus field_value(data, 'cpus')
    disk_size field_value(data, 'disk_size')
    disk_driver_type field_value(data, 'disk_driver_type')
    ram field_value(data, 'ram')
    bridge field_value(data, 'bridge')
    auto_boot field_value(data, 'auto_boot')
    pxe_boot field_value(data, 'pxe_boot')
    ctime field_value(data, 'ctime')
    mtime field_value(data, 'mtime')
    power_type field_value(data, 'power_type')
    power_address field_value(data, 'power_address')
    power_user field_value(data, 'power_user')
    power_pass field_value(data, 'power_pass')
    power_id field_value(data, 'power_id')
    hostname field_value(data, 'hostname')
    gateway field_value(data, 'gateway')
    name_servers field_value(data, 'name_servers')
    name_servers_search_path field_value(data, 'name_servers_search_path')
    ipv6_default_device field_value(data, 'ipv6_default_device')
    ipv6_autoconfiguration field_value(data, 'ipv6_autoconfiguration')
    mac_address field_value(data, 'mac_address')
    connected_mode field_value(data, 'connected_mode')
    mtu field_value(data, 'mtu')
    ip_address field_value(data, 'ip_address')
    interface_type field_value(data, 'interface_type')
    bonding field_value(data, 'bonding')
    interface_master field_value(data, 'interface_master')
    bonding_master field_value(data, 'bonding_master')
    bonding_opts field_value(data, 'bonding_opts')
    bridge_opts field_value(data, 'bridge_opts')
    management field_value(data, 'management')
    static field_value(data, 'static')
    netmask field_value(data, 'netmask')
    subnet field_value(data, 'subnet')
    if_gateway field_value(data, 'if_gateway')
    dhcp_tag field_value(data, 'dhcp_tag')
    dns_name field_value(data, 'dns_name')
    static_routes field_value(data, 'static_routes')
    ipv6_address field_value(data, 'ipv6_address')
    ipv6_prefix field_value(data, 'ipv6_prefix')
    ipv6_secondaries field_value(data, 'ipv6_secondaries')
    ipv6_mtu field_value(data, 'ipv6_mtu')
    ipv6_static_routes field_value(data, 'ipv6_static_routes')
    ipv6_default_gateway field_value(data, 'ipv6_default_gateway')
    mgmt_classes field_value(data, 'mgmt_classes')
    mgmt_parameters field_value(data, 'mgmt_parameters')
    boot_files field_value(data, 'boot_files')
    fetchable_files field_value(data, 'fetchable_files')
    template_files field_value(data, 'template_files')
    redhat_management_key field_value(data, 'redhat_management_key')
    redhat_management_server field_value(data, 'redhat_management_server')
    template_remote_kickstarts field_value(data, 'template_remote_kickstarts')
    repos_enabled field_value(data, 'repos_enabled')
    ldap_enabled field_value(data, 'ldap_enabled')
    ldap_type field_value(data, 'ldap_type')
    monit_enabled field_value(data, 'monit_enabled')
    cnames field_value(data, 'cnames')
    interface field_value(data, 'interface')
    delete_interface field_value(data, 'delete_interface')
    rename_interface field_value(data, 'rename_interface')
    clobber field_value(data, 'clobber')
    in_place field_value(data, 'in_place')
  end
end

#------------------------------------------------------------
# Queries Cobbler to determine if a specific image exists.
#------------------------------------------------------------
def exists?
  Chef::Log.debug("Checking if image '#{name}' already exists")
  if name.nil?
    false
  else
    find_command = "cobbler system find --name=#{name} | grep '#{name}'"
    Chef::Log.debug("Searching for system '#{name}' using #{find_command}")
    system_find = Mixlib::ShellOut.new(find_command)
    system_find.run_command
    Chef::Log.debug("Standard out from 'system find' is #{system_find.stdout.chomp}")

    # True if the value in stdout matches our name
    (system_find.stdout.chomp == name)
  end
end

unless defined? SYSTEM_FIELDS
  SYSTEM_FIELDS = {
    'TFTP Boot Files' => { attribute: 'boot_files', type: 'hash' },
    'Comment' => { attribute: 'comment', type: 'string' },
    'Enable gPXE' => { attribute: 'enable_gpxe', type: 'string' },
    'Fetchable Files' => { attribute: 'fetchable_files', type: 'hash' },
    'Gateway' => { attribute: 'gateway', type: 'string' },
    'Hostname' => { attribute: 'hostname', type: 'string' },
    'Image' => { attribute: 'image', type: 'string' },
    'IPv6 Autoconfiguration' => { attribute: 'ipv6_autoconfiguration', type: 'string' },
    'IPv6 Default Device' => { attribute: 'ipv6_default_device', type: 'string' },
    'Kernel Options' => { attribute: 'kickstart_options', type: 'hash' },
    'Kernel Options (Post Install' => { attribute: 'kickstart_options_post', type: 'hash' },
    'Kickstart' => { attribute: 'kickstart', type: 'string' },
    'Kickstart Metadata' => { attribute: 'ksmeta', type: 'hash' },
    'LDAP Enabled' => { attribute: 'ldap_enabled', type: 'string' },
    'LDAP Management Type' => { attribute: 'ldap_type', type: 'string' },
    'Management Classes' => { attribute: 'mgmt_classes', type: 'array' },
    'Management Parameters' => { attribute: 'mgmt_parameters', type: 'string' },
    'Monit Enabled' => { attribute: 'monit_enabled', type: 'string' },
    'Name Servers' => { attribute: 'name_servers', type: 'hash' },
    'Name Servers Search Path' => { attribute: 'name_servers_search_path', type: 'hash' },
    'Netboot Enabled' => { attribute: 'netboot_enabled', type: 'string' },
    'Owners' => { attribute: 'owners', type: 'string' },
    'Power Management Address' => { attribute: 'power_address', type: 'string' },
    'Power Management ID' => { attribute: 'power_id', type: 'string' },
    'Power Management Password' => { attribute: 'power_pass', type: 'string' },
    'Power Management Type' => { attribute: 'power_type', type: 'string' },
    'Power Management Username' => { attribute: 'power_user', type: 'string' },
    'Profile' => { attribute: 'profile', type: 'string' },
    'Internal proxy' => { attribute: 'proxy', type: 'string' },
    'Red Hat Management Key' => { attribute: 'redhat_management_key', type: 'string' },
    'Red Hat Management Server' => { attribute: 'redhat_management_server', type: 'string' },
    'Repos Enabled' => { attribute: 'repos_enabled', type: 'string' },
    'Server Override' => { attribute: 'server', type: 'string' },
    'Status' => { attribute: 'status', type: 'string' },
    'Template Files' => { attribute: 'template_files', type: 'hash' },
    'Virt Auto Boot' => { attribute: 'auto_boot', type: 'string' },
    'Virt CPUs' => { attribute: 'cpus', type: 'string' },
    'Virt Disk Driver Type' => { attribute: 'disk_driver_type', type: 'string' },
    'Virt File Size(GB)' => { attribute: 'disk_size', type: 'string' },
    'Virt Path' => { attribute: 'disk_path', type: 'string' },
    'Virt PXE Boot' => { attribute: 'pxe_boot', type: 'string' },
    'Virt RAM (MB)' => { attribute: 'ram', type: 'string' },
    'Virt Type' => { attribute: 'virtualization_type', type: 'string' },
    'Interface' => { attribute: 'interface', type: 'string' },
    'Bonding Opts' => { attribute: 'bonding_opts', type: 'string' },
    'Bridge Opts' => { attribute: 'bridge_opts', type: 'string' },
    'CNAMES' => { attribute: 'cnames', type: 'array' },
    'InfiniBand Connected Mode' => { attribute: 'connected_mode', type: 'string' },
    'DHCP Tag' => { attribute: 'dhcp_tag', type: 'string' },
    'DNS Name' => { attribute: 'dns_name', type: 'string' },
    'Per-Interface Gateway' => { attribute: 'if_gateway', type: 'string' },
    'Master Interface' => { attribute: 'interface_master', type: 'string' },
    'Interface Type' => { attribute: 'interface_type', type: 'string' },
    'IP Address' => { attribute: 'ip_address', type: 'string' },
    'IPv6 Address' => { attribute: 'ipv6_address', type: 'string' },
    'IPv6 Default Gateway' => { attribute: 'ipv6_default_gateway', type: 'string' },
    'IPv6 MTU' => { attribute: 'ipv6_mtu', type: 'string' },
    'IPv6 Prefix' => { attribute: 'ipv6_prefix', type: 'string' },
    'IPv6 Secondaries' => { attribute: 'ipv6_secondaries', type: 'array' },
    'IPv6 Static Routes' => { attribute: 'ipv6_static_routes', type: 'array' },
    'MAC Address' => { attribute: 'mac_address', type: 'string' },
    'Management Interface' => { attribute: 'mgmt_interface', type: 'string' },
    'MTU' => { attribute: 'mtu', type: 'string' },
    'Subnet Mask' => { attribute: 'subnet', type: 'string' },
    'Static' => { attribute: 'static', type: 'string' },
    'Static Routes' => { attribute: 'static_routes', type: 'array' },
    'Virt Bridge' => { attribute: 'virt_bridge', type: 'string' }
  }.freeze
end


def load_cobbler_system # rubocop:disable Metrics/AbcSize
  command = "cobbler system report --name='#{new_resource.name}'"
  shellout = Mixlib::ShellOut.new(command)
  shellout.run_command
  rc = "Return code: #{shellout.exitstatus}"
  stdout = "Stdout: #{shellout.stdout.chomp}"
  stderr = "Stderr: #{shellout.stderr.chomp}"
  if shellout.error?
    Chef::Log.fatal("Cobbler execution failed with:\n#{stderr}\n#{stdout}\n#{rc}")
    raise "Cobbler execution failed with #{stderr} (RC=#{rc})"
  end

  shellout.stdout.split("\n")
end

def field_value(input, field)
  value = nil
  input.each do |line_item|
    line_item.chomp!
    parts = line_item.split(':')
    parts[0].strip!
    parts[1].strip!

    # Skip the line read from the Cobbler output if the field name in the line is not part of our property set.
    next unless SYSTEM_FIELDS.key?(parts[0])

    # Get the attribute / property name used in our Hash constant so it can be compared to the requested 'field'; if
    # they match, then grab the value from the output and return it.
    next unless SYSTEM_FIELDS[parts[0]][:attribute] == field
    value = convert_field_value(SYSTEM_FIELDS[parts[0]][:type], parts[1])
  end

  value
end

def convert_field_value(field_type, field_value) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
  retval = nil

  case field_type
  when 'hash'
    # Parse as JSON
    retval = JSON.parse(field_value)
  when 'array'
    if field_value == '[]'
      retval = nil
    else
      # Strip braces and parse as CSV
      retval = field_value[1..-2].split(',')
      retval.map do |val|
        val.gsub!(/'/, '')
      end
    end
  when 'boolean'
    if field_value == '1' || field_value == 'true' || field_value == 'True'
      retval = true
    else
      retval = false
    end
  else
    retval = (field_value == '<<inherit>>' ? '' : field_value.chomp)
  end

  retval
end

action_class do
  #------------------------------------------------------------
  # Defines the allowable architectures, used for input validation.
  # TODO: Move the list of architectures and breeds to a helper method so they are globally accessible.
  #------------------------------------------------------------
  def architectures
    %w[i386 x86_64 ia64 ppc ppc64 ppc64le s390 arm noarch src]
  end

  #------------------------------------------------------------
  # Defines the allowable breed for the image type, used for input validation.
  #------------------------------------------------------------
  def breeds
    %w[suse redhat windows xen generic unix freebsd ubuntu nexenta debian vmware]
  end

  #------------------------------------------------------------
  # Validates that the provided inputs do not include any reserved words or separate characters
  #------------------------------------------------------------
  def validate_input
    # TODO: Write some validation
  end

  require 'etc'
  require 'digest'
end
