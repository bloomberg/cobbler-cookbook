# Base Resource
provides :cobbler_system
resource_name :cobbler_system

# Actions that we support.  Must be stated in our provider action :create do.
actions :create, :delete

# Our default action, can be anything.
default_action :create if defined?(default_action)

# Name Space, this is what is passed in "<name>".
property :name, name_attribute: true, kind_of: String, required: true

property :auto_boot, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :boot_files, kind_of: Hash, required: false, desired_state: false, default: {}
property :clobber, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :comment, kind_of: String, required: false, desired_state: false, default: nil
property :connected_mode, kind_of: String, required: false, desired_state: false, default: nil
property :cpus, kind_of: String, required: false, desired_state: false, default: nil
property :ctime, kind_of: String, required: false, desired_state: false, default: nil
property :depth, kind_of: Integer, required: false, desired_state: false, default: 0
property :disk_driver_type, kind_of: String, required: false, desired_state: false, default: nil
property :disk_path, kind_of: String, required: false, desired_state: false, default: nil
property :disk_size, kind_of: String, required: false, desired_state: false, default: nil
property :dns_name, kind_of: String, required: false, desired_state: false, default: nil
property :enable_gpxe, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :fetchable_files, kind_of: Hash, required: false, desired_state: false, default: {}
property :gateway, kind_of: String, required: false, desired_state: false, default: nil
property :hostname, kind_of: String, required: false, desired_state: false, default: nil
property :image, kind_of: String, required: false, desired_state: false, default: nil
property :in_place, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :interfaces, kind_of: Hash, required: false, desired_state: false, default: {}
property :ipv6_autoconfiguration, kind_of: String, required: false, desired_state: false, default: nil
property :ipv6_default_device, kind_of: String, required: false, desired_state: false, default: nil
property :kickstart, kind_of: String, required: false, desired_state: false, default: nil
property :kickstart_options, kind_of: String, required: false, desired_state: false, default: nil
property :kickstart_options_post, kind_of: String, required: false, desired_state: false, default: nil
property :ksmeta, kind_of: String, required: false, desired_state: false, default: nil
property :ldap_enabled, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :ldap_type, kind_of: String, required: false, desired_state: false, default: nil
property :mgmt_classes, kind_of: Array, required: false, desired_state: false, default: []
property :mgmt_parameters, kind_of: String, required: false, desired_state: false, default: nil
property :monit_enabled, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :mtime, kind_of: String, required: false, desired_state: false, default: nil
property :name_servers, kind_of: Array, required: false, desired_state: false, default: []
property :name_servers_search_path, kind_of: String, required: false, desired_state: false, default: nil
property :netboot_enabled, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :netmask, kind_of: String, required: false, desired_state: false, default: nil
property :owners, kind_of: Array, required: true, desired_state: false, default: ['admin']
property :power_address, kind_of: String, required: false, desired_state: false, default: nil
property :power_id, kind_of: String, required: false, desired_state: false, default: nil
property :power_pass, kind_of: String, required: false, desired_state: false, default: nil
property :power_type, kind_of: String, required: false, desired_state: false, default: nil
property :power_user, kind_of: String, required: false, desired_state: false, default: nil
property :profile, kind_of: String, required: false, desired_state: false, default: nil
property :proxy, kind_of: String, required: false, desired_state: false, default: nil
property :pxe_boot, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :ram, kind_of: Integer, required: false, desired_state: false, default: nil
property :redhat_management_key, kind_of: String, required: false, desired_state: false, default: nil
property :redhat_management_server, kind_of: String, required: false, desired_state: false, default: nil
property :rename_interface, kind_of: String, required: false, desired_state: false, default: nil
property :repos_enabled, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :server, kind_of: String, required: false, desired_state: false, default: nil
property :status, kind_of: String, required: false, desired_state: false, default: nil
property :template_files, kind_of: Hash, required: false, desired_state: false, default: {}
property :template_remote_kickstarts, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :uid, kind_of: String, required: false, desired_state: false, default: nil
property :virtualization_type, kind_of: String, required: false, desired_state: false, default: nil

# This is a standard ruby accessor, use this to set flags for current state.
attr_accessor :exists

action :create do
  # TODO: Add check to ensure that the specified profile exists.
  validate_input

  if !exists?
    # Setup command with known required attributes. Since only name is required to delete, that is all we're using.
    system_command = "cobbler system add --name=#{new_resource.name}"

    # Setup command with known required attributes
    system_command = "#{system_command} --auto-boot='#{new_resource.auto_boot}'" if new_resource.auto_boot
    system_command = "#{system_command} --boot-files='#{new_resource.boot_files}'" if new_resource.boot_files
    system_command = "#{system_command} --clobber='#{new_resource.clobber}'" if new_resource.clobber
    system_command = "#{system_command} --comment='#{new_resource.comment}'" if new_resource.comment
    system_command = "#{system_command} --connected_mode='#{new_resource.connected_mode}'" if new_resource.connected_mode
    system_command = "#{system_command} --cpus='#{new_resource.cpus}'" if new_resource.cpus
    system_command = "#{system_command} --disk-driver-type='#{new_resource.disk_driver_type}'" if new_resource.disk_driver_type
    system_command = "#{system_command} --disk-path='#{new_resource.disk_path}'" if new_resource.disk_path
    system_command = "#{system_command} --disk-size='#{new_resource.disk_size}'" if new_resource.disk_size
    system_command = "#{system_command} --enable-gpxe='#{new_resource.enable_gpxe}'" if new_resource.enable_gpxe
    system_command = "#{system_command} --fetchable-files='#{new_resource.fetchable_files}'" if new_resource.fetchable_files
    system_command = "#{system_command} --gateway='#{new_resource.gateway}'" if new_resource.gateway
    system_command = "#{system_command} --hostname='#{new_resource.hostname}'" if new_resource.hostname
    system_command = "#{system_command} --image='#{new_resource.image}'" if new_resource.image
    system_command = "#{system_command} --in-place='#{new_resource.in_place}'" if new_resource.in_place
    system_command = "#{system_command} --kickstart='#{new_resource.kickstart}'" if new_resource.kickstart
    system_command = "#{system_command} --kickstart-options='#{new_resource.kickstart_options}'" if new_resource.kickstart_options
    system_command = "#{system_command} --kickstart-options-post='#{new_resource.kickstart_options_post}'" if new_resource.kickstart_options_post
    system_command = "#{system_command} --ksmeta='#{new_resource.ksmeta}'" if new_resource.ksmeta
    system_command = "#{system_command} --ldap-enabled='#{new_resource.ldap_enabled}'" if new_resource.ldap_enabled
    system_command = "#{system_command} --ldap-type='#{new_resource.ldap_type}'" if new_resource.ldap_type
    system_command = "#{system_command} --mgmt-classes='#{new_resource.mgmt_classes.join(',')}'" if new_resource.mgmt_classes
    system_command = "#{system_command} --mgmt-parameters='#{new_resource.mgmt_parameters}'" if new_resource.mgmt_parameters
    system_command = "#{system_command} --monit-enabled='#{new_resource.monit_enabled}'" if new_resource.monit_enabled
    system_command = "#{system_command} --name-servers='#{new_resource.name_servers}'" if new_resource.name_servers
    system_command = "#{system_command} --name-servers-search-path='#{new_resource.name_servers_search_path}'" if new_resource.name_servers_search_path
    system_command = "#{system_command} --netboot-enabled='#{new_resource.netboot_enabled}'" if new_resource.netboot_enabled
    system_command = "#{system_command} --owners='#{new_resource.owners.join(',')}'"
    system_command = "#{system_command} --power-address='#{new_resource.power_address}'" if new_resource.power_address
    system_command = "#{system_command} --power-id='#{new_resource.power_id}'" if new_resource.power_id
    system_command = "#{system_command} --power-pass='#{new_resource.power_pass}'" if new_resource.power_pass
    system_command = "#{system_command} --power-type='#{new_resource.power_type}'" if new_resource.power_type
    system_command = "#{system_command} --power-user='#{new_resource.power_user}'" if new_resource.power_user
    system_command = "#{system_command} --profile='#{new_resource.profile}'" if new_resource.profile
    system_command = "#{system_command} --proxy='#{new_resource.proxy}'" if new_resource.proxy
    system_command = "#{system_command} --pxe-boot='#{new_resource.pxe_boot}'" if new_resource.pxe_boot
    system_command = "#{system_command} --ram='#{new_resource.ram}'" if new_resource.ram
    system_command = "#{system_command} --redhat-management-key='#{new_resource.redhat_management_key}'" if new_resource.redhat_management_key
    system_command = "#{system_command} --redhat-management-server='#{new_resource.redhat_management_server}'" if new_resource.redhat_management_server
    system_command = "#{system_command} --rename-interface='#{new_resource.rename_interface}'" if new_resource.rename_interface
    system_command = "#{system_command} --repos-enabled='#{new_resource.repos_enabled}'" if new_resource.repos_enabled
    system_command = "#{system_command} --server='#{new_resource.server}'" if new_resource.server
    system_command = "#{system_command} --status='#{new_resource.status}'" if new_resource.status
    system_command = "#{system_command} --template-files='#{new_resource.template_files}'" if new_resource.template_files
    system_command = "#{system_command} --template-remote-kickstarts=#{new_resource.template_remote_kickstarts}" if new_resource.template_remote_kickstarts
    system_command = "#{system_command} --virtualization-type='#{new_resource.virtualization_type}'" if new_resource.virtualization_type

    bash "#{new_resource.name}-cobbler-system-create" do
      code system_command
      notifies :run, 'bash[cobbler-sync]', :delayed
    end

    new_resource.interfaces.each do |ifname, ifsettings|
      system_command = "cobbler system edit --inplace --name=#{new_resource.name}"

      # TODO: Interfaces can be specified only one at a time. This means that the first interface can be configured
      # when adding the system; any additional interfaces must make separate 'cobbler system edit' calls, one for each
      # additional interface.
      system_command = "#{system_command} --interface='#{ifname}'"
      system_command = "#{system_command} --bonding-opts='#{ifsettings['bonding_opts']}'" if ifsettings.key?('bonding_opts')
      system_command = "#{system_command} --bridge_opts='#{ifsettings['bridge_opts']}'" if ifsettings.key?('bridge_opts')
      system_command = "#{system_command} --cnames='#{ifsettings['cnames']}'" if ifsettings.key?('cnames')
      system_command = "#{system_command} --dhcp-tag='#{ifsettings['dhcp_tag']}'" if ifsettings.key?('dhcp_tag')
      system_command = "#{system_command} --dns-name='#{ifsettings['dns_name']}'" if ifsettings.key?('dns_name')
      system_command = "#{system_command} --interface-type='#{ifsettings['interface_type']}'" if ifsettings.key?('interface_type')
      system_command = "#{system_command} --interface-master='#{ifsettings['interface_master']}'" if ifsettings.key?('interface_master')
      system_command = "#{system_command} --ip-address='#{ifsettings['ip_address']}'" if ifsettings.key?('ip_address')
      system_command = "#{system_command} --ipv6-address='#{ifsettings['ipv6_address']}'" if ifsettings.key?('ipv6_address')
      system_command = "#{system_command} --ipv6-autoconfiguration='#{new_resource.ipv6_autoconfiguration}'" if new_resource.ipv6_autoconfiguration
      system_command = "#{system_command} --ipv6-default-device" if ifsettings.key?('ipv6_address')
      system_command = "#{system_command} --ipv6-secondaries='#{ifsettings['ipv6_secondaries']}'" if ifsettings.key?('ipv6_secondaries')
      system_command = "#{system_command} --ipv6-mtu='#{ifsettings['ipv6_mtu']}'" if ifsettings.key?('ipv6_mtu')
      system_command = "#{system_command} --ipv6-static-routes='#{ifsettings['ipv6_static_routes']}'" if ifsettings.key?('ipv6_static_routes')
      system_command = "#{system_command} --ipv6-default-gateway='#{ifsettings['ipv6_default_gateway']}'" if ifsettings.key?('ipv6_default_gateway')
      system_command = "#{system_command} --mac-address='#{ifsettings['mac_address']}'" if ifsettings.key?('mac_address')
      system_command = "#{system_command} --mtu='#{ifsettings['mtu']}'" if ifsettings.key?('mtu')
      system_command = "#{system_command} --management='#{ifsettings['management']}'" if ifsettings.key?('management')
      system_command = "#{system_command} --static='#{ifsettings['static']}'" if ifsettings.key?('static')
      system_command = "#{system_command} --static-routes='#{ifsettings['static_routes']}'" if ifsettings.key?('static_routes')
      system_command = "#{system_command} --netmask='#{ifsettings['netmask']}'" if ifsettings.key?('netmask')
      system_command = "#{system_command} --netmask='#{ifsettings['subnet']}'" if ifsettings.key?('subnet')
      system_command = "#{system_command} --virt-bridge='#{ifsettings['virt_bridge']}'" if ifsettings.key?('virt_bridge')

      bash "#{new_resource.name}-cobbler-system-addif-#{ifname}" do
        code system_command
        notifies :run, 'bash[cobbler-sync]', :delayed
      end
    end
  end
end

action :delete do
  if exists?
    # Setup command with known required attributes. Since only name is required to delete, that is all we're using.
    system_command = "cobbler system remove --name=#{name}"

    Chef::Log.debug "Will delete existing OS distro using the command '#{system_command}'"
    bash "#{name}-cobbler-distro-remove" do
      code system_command
      umask 0o0002
    end
  end
end

load_current_value do
  if exists?
    data = load_cobbler_system

    # TODO: Use the 'send' feature / function to programatically (and dynamically) do this.
    auto_boot true_false_value(data['auto_boot'])
    boot_files data['boot_files']
    comment data['comment']
    connected_mode data['connected_mode']
    cpus data['cpus']
    ctime data['ctime'].to_s
    depth data['depth']
    disk_driver_type data['disk_driver_type']
    disk_path data['disk_path']
    disk_size data['disk_size']
    enable_gpxe true_false_value(data['enable_gpxe'])
    fetchable_files data['fetchable_files']
    gateway data['gateway']
    hostname data['hostname']
    image data['image']
    interfaces data['interfaces']
    kickstart data['kickstart']
    kickstart_options data['kickstart_options']
    kickstart_options_post data['kickstart_options_post']
    ksmeta data['ksmeta']
    ldap_enabled true_false_value(data['ldap_enabled'])
    ldap_type data['ldap_type']
    mgmt_classes array_value(data['mgmt_classes'])
    mgmt_parameters data['mgmt_parameters']
    monit_enabled true_false_value(data['monit_enabled'])
    mtime data['mtime'].to_s
    name_servers data['name_servers']
    name_servers_search_path data['name_servers_search_path']
    netboot_enabled data['netboot_enabled']
    owners data['owners']
    power_address data['power_address']
    power_id data['power_id']
    power_pass data['power_pass']
    power_type data['power_type']
    power_user data['power_user']
    profile data['profile']
    proxy data['proxy']
    pxe_boot data['pxe_boot']
    ram data['ram']
    redhat_management_key data['redhat_management_key']
    redhat_management_server data['redhat_management_server']
    repos_enabled true_false_value(data['repos_enabled'])
    server data['server']
    status data['status']
    template_files data['template_files']
    template_remote_kickstarts true_false_value(data['template_remote_kickstarts'])
    uid data['uid']
    virtualization_type data['virtualization_type']
  end
end

def true_false_value(value)
  if value.nil? || value == '<<inheirit>>'
    nil
  elsif value == "true" || value.to_s == "1"
    true
  else
    false
  end
end

def array_value(value)
  if value.nil? || value == '<<inherit>>'
    nil
  else
    value
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

def load_cobbler_system # rubocop:disable Metrics/AbcSize
  retval = {}
  config_file = ::File.join('/var/lib/cobbler/config/systems.d/', "#{name}.json")
  if ::File.exist?(config_file)
    retval = JSON.parse(::File.read(config_file))
  else
    Chef::Log.error("Configuration file #{config_file} needed to load the existing system does not exist")
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
