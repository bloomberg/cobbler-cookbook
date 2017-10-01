# Base Provider
include Cobbler::Parse

# Notifications are impacted here. If you do delayed notifications, they will be performed at the
# end of the resource run and not at the end of the chef run. You do want to use this as it also
# affects internal resource notifications.
use_inline_resources

#------------------------------------------------------------
# Create Action
#------------------------------------------------------------
action :create do
  # Only create if it does not exist.
  if @current_resource.exists
    Chef::Log.warn "A system named #{@current_resource.name} already exists. Not creating."
    # Use this to raise exceptions that stop a chef run.
    # raise "Our file already exists."
  else
    # Converge our node
    converge_by("Creating Cobbler system #{@new_resource.base_name}") do
      resp = create
      # We set our updated flag based on the resource we utilized.
      @new_resource.updated_by_last_action(resp)
    end
  end
end

#------------------------------------------------------------
# Delete Action
#------------------------------------------------------------
action :delete do
  # Only delete if it exists.
  if @current_resource.exists
    # Converge our node
    converge_by("Deleting Cobbler system #{@new_resource.base_name}") do
      resp = delete
      @new_resource.updated_by_last_action(resp)
    end
  else
    Chef::Log.warn "The system #{@new_resource.base_name} does not exist, nothing was deleted."
  end
end

#------------------------------------------------------------
# Support Simulated Runs
#------------------------------------------------------------
def whyrun_supported?
  true
end

#------------------------------------------------------------
# Override Load Current Resource
#------------------------------------------------------------
def load_current_resource
  if exists?(@new_resource.base_name)
    @current_resource = load_system(@new_resource)
    @current_resource.exists = true
  else
    @current_resource = @new_resource.clone
    @current_resource.exists = false
  end
end

#------------------------------------------------------------
# Queries Cobbler to determine if a specific image exists.
#------------------------------------------------------------
def exists?(system_name = nil)
  Chef::Log.debug("Checking if system '#{system_name}' already exists")
  if system_name.nil?
    false
  else
    find_command = "cobbler system find --name=#{system_name} | grep '#{system_name}'"
    Chef::Log.info("Searching for '#{system_name}' using #{find_command}")
    find = Mixlib::ShellOut.new(find_command)
    find.run_command
    Chef::Log.info("Standard out from 'system find' is #{find.stdout.chomp}")
    (find.stdout.chomp == system_name)
  end
end

#------------------------------------------------------------
# Create a Cobbler system definition if it doesn't exist.
#------------------------------------------------------------
def create # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
  # Setup command with known required attributes. Since only name is required to delete, that is all we're using.
  system_command = "cobbler system add --name=#{@current_resource.base_name}"

  # Setup command with known required attributes
  system_command = "#{system_command} --uid='#{@new_resource.uid}'" if @new_resource.uid
  system_command = "#{system_command} --owners='#{@new_resource.owners.join(',')}'"
  system_command = "#{system_command} --profile='#{@new_resource.profile}'" if @new_resource.profile
  system_command = "#{system_command} --image='#{@new_resource.image}'" if @new_resource.image
  system_command = "#{system_command} --status='#{@new_resource.status}'" if @new_resource.status
  system_command = "#{system_command} --kickstart_options='#{@new_resource.kickstart_options}'" if @new_resource.kickstart_options
  system_command = "#{system_command} --kickstart_options_post='#{@new_resource.kickstart_options_post}'" if @new_resource.kickstart_options_post
  system_command = "#{system_command} --ksmeta='#{@new_resource.ksmeta}'" if @new_resource.ksmeta
  system_command = "#{system_command} --enable_gpxe='#{@new_resource.enable_gpxe}'" if @new_resource.enable_gpxe
  system_command = "#{system_command} --proxy='#{@new_resource.proxy}'" if @new_resource.proxy
  system_command = "#{system_command} --netboot_enabled='#{@new_resource.netboot_enabled}'" if @new_resource.netboot_enabled
  system_command = "#{system_command} --kickstart='#{@new_resource.kickstart}'" if @new_resource.kickstart
  system_command = "#{system_command} --comment='#{@new_resource.comment}'" if @new_resource.comment
  system_command = "#{system_command} --depth='#{@new_resource.depth}'" if @new_resource.depth
  system_command = "#{system_command} --server='#{@new_resource.server}'" if @new_resource.server
  system_command = "#{system_command} --disk_path='#{@new_resource.disk_path}'" if @new_resource.disk_path
  system_command = "#{system_command} --virtualization_type='#{@new_resource.virtualization_type}'" if @new_resource.virtualization_type
  system_command = "#{system_command} --cpus='#{@new_resource.cpus}'" if @new_resource.cpus
  system_command = "#{system_command} --disk_size='#{@new_resource.disk_size}'" if @new_resource.disk_size
  system_command = "#{system_command} --disk_driver_type='#{@new_resource.disk_driver_type}'" if @new_resource.disk_driver_type
  system_command = "#{system_command} --ram='#{@new_resource.ram}'" if @new_resource.ram
  system_command = "#{system_command} --bridge='#{@new_resource.bridge}'" if @new_resource.bridge
  system_command = "#{system_command} --auto_boot='#{@new_resource.auto_boot}'" if @new_resource.auto_boot
  system_command = "#{system_command} --pxe_boot='#{@new_resource.pxe_boot}'" if @new_resource.pxe_boot
  system_command = "#{system_command} --ctime='#{@new_resource.ctime}'" if @new_resource.ctime
  system_command = "#{system_command} --mtime='#{@new_resource.mtime}'" if @new_resource.mtime
  system_command = "#{system_command} --power_type='#{@new_resource.power_type}'" if @new_resource.power_type
  system_command = "#{system_command} --power_address='#{@new_resource.power_address}'" if @new_resource.power_address
  system_command = "#{system_command} --power_user='#{@new_resource.power_user}'" if @new_resource.power_user
  system_command = "#{system_command} --power_pass='#{@new_resource.power_pass}'" if @new_resource.power_pass
  system_command = "#{system_command} --power_id='#{@new_resource.power_id}'" if @new_resource.power_id
  system_command = "#{system_command} --hostname='#{@new_resource.hostname}'" if @new_resource.hostname
  system_command = "#{system_command} --gateway='#{@new_resource.gateway}'" if @new_resource.gateway
  system_command = "#{system_command} --name_servers='#{@new_resource.name_servers}'" if @new_resource.name_servers
  system_command = "#{system_command} --name_servers_search_path='#{@new_resource.name_servers_search_path}'" if @new_resource.name_servers_search_path
  system_command = "#{system_command} --ipv6_default_device='#{@new_resource.ipv6_default_device}'" if @new_resource.ipv6_default_device
  system_command = "#{system_command} --ipv6_autoconfiguration='#{@new_resource.ipv6_autoconfiguration}'" if @new_resource.ipv6_autoconfiguration
  system_command = "#{system_command} --mac_address='#{@new_resource.mac_address}'" if @new_resource.mac_address
  system_command = "#{system_command} --connected_mode='#{@new_resource.connected_mode}'" if @new_resource.connected_mode
  system_command = "#{system_command} --mtu='#{@new_resource.mtu}'" if @new_resource.mtu
  system_command = "#{system_command} --ip_address='#{@new_resource.ip_address}'" if @new_resource.ip_address
  system_command = "#{system_command} --interface_type='#{@new_resource.interface_type}'" if @new_resource.interface_type
  system_command = "#{system_command} --bonding='#{@new_resource.bonding}'" if @new_resource.bonding
  system_command = "#{system_command} --interface_master='#{@new_resource.interface_master}'" if @new_resource.interface_master
  system_command = "#{system_command} --bonding_master='#{@new_resource.bonding_master}'" if @new_resource.bonding_master
  system_command = "#{system_command} --bonding_opts='#{@new_resource.bonding_opts}'" if @new_resource.bonding_opts
  system_command = "#{system_command} --bridge_opts='#{@new_resource.bridge_opts}'" if @new_resource.bridge_opts
  system_command = "#{system_command} --management='#{@new_resource.management}'" if @new_resource.management
  system_command = "#{system_command} --static='#{@new_resource.static}'" if @new_resource.static
  system_command = "#{system_command} --netmask='#{@new_resource.netmask}'" if @new_resource.netmask
  system_command = "#{system_command} --subnet='#{@new_resource.subnet}'" if @new_resource.subnet
  system_command = "#{system_command} --if_gateway='#{@new_resource.if_gateway}'" if @new_resource.if_gateway
  system_command = "#{system_command} --dhcp_tag='#{@new_resource.dhcp_tag}'" if @new_resource.dhcp_tag
  system_command = "#{system_command} --dns_name='#{@new_resource.dns_name}'" if @new_resource.dns_name
  system_command = "#{system_command} --static_routes='#{@new_resource.static_routes}'" if @new_resource.static_routes
  system_command = "#{system_command} --ipv6_address='#{@new_resource.ipv6_address}'" if @new_resource.ipv6_address
  system_command = "#{system_command} --ipv6_prefix='#{@new_resource.ipv6_prefix}'" if @new_resource.ipv6_prefix
  system_command = "#{system_command} --ipv6_secondaries='#{@new_resource.ipv6_secondaries}'" if @new_resource.ipv6_secondaries
  system_command = "#{system_command} --ipv6_mtu='#{@new_resource.ipv6_mtu}'" if @new_resource.ipv6_mtu
  system_command = "#{system_command} --ipv6_static_routes='#{@new_resource.ipv6_static_routes}'" if @new_resource.ipv6_static_routes
  system_command = "#{system_command} --ipv6_default_gateway='#{@new_resource.ipv6_default_gateway}'" if @new_resource.ipv6_default_gateway
  system_command = "#{system_command} --mgmt_classes='#{@new_resource.mgmt_classes}'" if @new_resource.mgmt_classes
  system_command = "#{system_command} --mgmt_parameters='#{@new_resource.mgmt_parameters}'" if @new_resource.mgmt_parameters
  system_command = "#{system_command} --boot_files='#{@new_resource.boot_files}'" if @new_resource.boot_files
  system_command = "#{system_command} --fetchable_files='#{@new_resource.fetchable_files}'" if @new_resource.fetchable_files
  system_command = "#{system_command} --template_files='#{@new_resource.template_files}'" if @new_resource.template_files
  system_command = "#{system_command} --redhat_management_key='#{@new_resource.redhat_management_key}'" if @new_resource.redhat_management_key
  system_command = "#{system_command} --redhat_management_server='#{@new_resource.redhat_management_server}'" if @new_resource.redhat_management_server
  system_command = "#{system_command} --template_remote_kickstarts='#{@new_resource.template_remote_kickstarts}'" if @new_resource.template_remote_kickstarts
  system_command = "#{system_command} --repos_enabled='#{@new_resource.repos_enabled}'" if @new_resource.repos_enabled
  system_command = "#{system_command} --ldap_enabled='#{@new_resource.ldap_enabled}'" if @new_resource.ldap_enabled
  system_command = "#{system_command} --ldap_type='#{@new_resource.ldap_type}'" if @new_resource.ldap_type
  system_command = "#{system_command} --monit_enabled='#{@new_resource.monit_enabled}'" if @new_resource.monit_enabled
  system_command = "#{system_command} --cnames='#{@new_resource.cnames}'" if @new_resource.cnames
  system_command = "#{system_command} --interface='#{@new_resource.interface}'" if @new_resource.interface
  system_command = "#{system_command} --delete_interface='#{@new_resource.delete_interface}'" if @new_resource.delete_interface
  system_command = "#{system_command} --rename_interface='#{@new_resource.rename_interface}'" if @new_resource.rename_interface
  system_command = "#{system_command} --clobber='#{@new_resource.clobber}'" if @new_resource.clobber
  system_command = "#{system_command} --in_place='#{@new_resource.in_place}'" if @new_resource.in_place

  Chef::Log.debug "Will add a new system using the command '#{system_command}'"
  bash "#{@current_resource.base_name}-cobbler-system-create" do
    code <<-CODE
      #{system_command}
    CODE
    umask 0o0002
  end

  # Return the state of the system; if it does not exist, then it was deleted.
  !exists?(@current_resource.base_name)
end

#------------------------------------------------------------
# Delete a Cobbler system definition if it exists.
#------------------------------------------------------------
def delete
  # Setup command with known required attributes. Since only name is required to delete, that is all we're using.
  system_command = "cobbler system remove --name=#{@current_resource.base_name}"

  Chef::Log.debug "Will delete existing system using the command '#{system_command}'"
  bash "#{@current_resource.base_name}-cobbler-system-delete" do
    code <<-CODE
      #{system_command}
    CODE
    umask 0o0002
  end

  # Return the state of the repository; if it does not exist, then it was deleted.
  !exists?(@current_resource.base_name)
end
