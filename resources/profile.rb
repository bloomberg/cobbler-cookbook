# Base Resource
provides :cobbler_profile
resource_name :cobbler_profile

actions :create, :delete

default_action :create

property :name, name_attribute: true, kind_of: String, required: true
property :distro, kind_of: String, required: false, desired_state: false, default: nil
property :comment, kind_of: String, required: false, desired_state: false, default: nil
property :kickstart, kind_of: String, required: false, desired_state: false, default: nil
property :kickstart_meta, kind_of: Hash, required: false, desired_state: false, default: {}
property :boot_files, kind_of: Hash, required: false, desired_state: false, default: nil
property :dhcp_tag, kind_of: String, required: false, desired_state: false, default: nil
property :enable_gpxe, kind_of: String, required: false, desired_state: false, default: nil
property :enable_pxe_menu, kind_of: String, required: false, desired_state: false, default: nil
property :fetchable_files, kind_of: Hash, required: false, desired_state: false, default: nil
property :kernel_options, kind_of: Hash, default: { interface: 'auto' }
property :kernel_options_postinstall, kind_of: Hash, default: {}
property :mgmt_classes, kind_of: Hash, required: false, desired_state: false, default: nil
property :mgmt_parameters, kind_of: String, required: false, desired_state: false, default: nil
property :name_servers, kind_of: String, required: false, desired_state: false, default: nil
property :name_servers_search_path, kind_of: String, required: false, desired_state: false, default: nil
property :owners, kind_of: Array, required: false, desired_state: false, default: ['admin']
property :parent_profile, kind_of: String, required: false, desired_state: false, default: nil
property :internal_proxy, kind_of: String, required: false, desired_state: false, default: nil
property :redhat_management_key, kind_of: String, required: false, desired_state: false, default: nil
property :redhat_management_server, kind_of: String, required: false, desired_state: false, default: nil
property :repos, kind_of: Array, required: false, desired_state: false, default: nil
property :server_override, kind_of: String, required: false, desired_state: false, default: nil
property :template_files, kind_of: String, required: false, desired_state: false, default: nil
property :auto_boot, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: nil
property :bridge, kind_of: String, required: false, desired_state: false, default: nil
property :cpus, kind_of: String, required: false, desired_state: false, default: nil
property :disk_driver_type, kind_of: String, required: false, desired_state: false, default: nil
property :disk_size, kind_of: String, required: false, desired_state: false, default: nil
property :disk_path, kind_of: String, required: false, desired_state: false, default: nil
property :ram, kind_of: String, required: false, desired_state: false, default: nil
property :virtualization_type, kind_of: String, required: false, desired_state: false, default: nil

# This is a standard ruby accessor, use this to set flags for current state.
attr_accessor :exists
attr_accessor :dependencies

action :create do
  # TODO: Add check to ensure that the specified distro exists.
  command = "cobbler profile add --name='#{@new_resource.name}'"
  command = "#{command} --distro='#{@new_resource.distro}'"
  command = "#{command} --kickstart='#{@new_resource.kickstart}'"

  unless new_resource.kernel_options.empty?
    command = "#{command} --kopts='#{new_resource.kernel_options.map { |k, v| "#{k}=#{v}" }.join(' ')}'"
  end

  unless new_resource.kernel_options_postinstall.empty?
    kop = new_resource.kernel_options_postinstall.map { |k, v| "#{k}=#{v}" }.join(' ')
    command = "#{command} --kopts-post='#{kop}'"
  end

  unless new_resource.kickstart_meta.empty?
    km = new_resource.kickstart_meta.map { |k, v| "#{k}=#{v}" }.join(' ')
    command = "#{command} --kickstart-meta='#{km}'"
  end

  Chef::Log.info("Final profile add command is #{command}")

  template "/var/lib/cobbler/kickstarts/#{new_resource.name}" do
    source "#{new_resource.kickstart}.erb"
    action :create
    not_if { new_resource.kickstart.nil? }
  end

  bash "#{new_resource.name}-cobbler-profile-add" do
    code command
    umask 0o0002
    notifies :run, 'bash[cobbler-sync]', :delayed
    not_if { exists? }
  end
end

action :delete do
  bash "#{new_resource.name}-cobbler-profile-delete" do
    code "cobbler profile remove --name='#{new_resource.name}'"
    notifies :run, 'bash[cobbler-sync]', :delayed
    only_if { exists? }
  end

  file "/var/lib/cobbler/kickstarts/#{new_resource.name}" do
    action :delete
    only_if { ::File.exist? "/var/lib/cobbler/kickstarts/#{new_resource.name}" }
  end
end

load_current_value do
  if exists?
    data = load_cobbler_profile

    # TODO: Use the 'send' feature / function to programatically (and dynamically) do this.
    name data['name']
    distro data['distro']
    comment data['comment']
    kickstart data['kickstart']
    kickstart_meta data['kickstart_meta']
    boot_files data['boot_files']
    dhcp_tag data['dhcp_tag']
    enable_gpxe data['enable_gpxe']
    enable_pxe_menu data['enable_pxe_menu']
    fetchable_files data['fetchable_files']
    kernel_options data['kernel_options']
    kernel_options_postinstall data['kernel_options_postinstall']
    mgmt_classes data['mgmt_classes']
    mgmt_parameters data['mgmt_parameters']
    name_servers data['name_servers']
    name_servers_search_path data['name_servers_search_path']
    owners data['owners']
    parent_profile data['parent_profile']
    internal_proxy data['internal_proxy']
    redhat_management_key data['redhat_management_key']
    redhat_management_server data['redhat_management_server']
    repos data['repos']
    server_override data['server_override']
    template_files data['template_files']
    auto_boot data['auto_boot']
    bridge data['bridge']
    cpus data['cpus']
    disk_driver_type data['disk_driver_type']
    disk_size data['disk_size']
    disk_path data['disk_path']
    ram data['ram']
    virtualization_type data['virtualization_type']
  end
end

#------------------------------------------------------------
# Queries Cobbler to determine if a specific repo exists.
#------------------------------------------------------------
def exists?
  Chef::Log.info("Checking if repository '#{name}' already exists")
  if name.nil?
    false
  else
    find_command = "cobbler profile find --name=#{name} | grep '#{name}'"
    Chef::Log.debug("Searching for '#{name}' using #{find_command}")
    find = Mixlib::ShellOut.new(find_command)
    find.run_command
    Chef::Log.debug("Standard out from 'profile find' is #{find.stdout.chomp}")
    # True if the value in stdout matches our name
    (find.stdout.chomp == name)
  end
end

unless defined? PROFILE_FIELDS
  PROFILE_FIELDS = {
    'Name' => { attribute: 'name', type: 'string' },
    # Parse as JSON
    'TFTP Boot Files' => { attribute: 'boot_files', type: 'hash' },
    'Comment' => { attribute: 'comment', type: 'string' },
    'DHCP Tag' => { attribute: 'dhcp_tag', type: 'string' },
    'Distribution' => { attribute: 'distro', type: 'string' },
    'Enable gPXE?' => { attribute: 'enable_gpxe', type: 'string' },
    'Enable PXE Menu?' => { attribute: 'enable_pxe_menu', type: 'string' },
    # Parse as JSON
    'Fetchable Files' => { attribute: 'fetchable_files', type: 'hash' },
    # Parse as JSON
    'Kernel Options' => { attribute: 'kernel_options', type: 'hash' },
    # Parse as JSON
    'Kernel Options (Post Install)' => { attribute: 'kernel_options_postinstall', type: 'hash' },
    # Parse as JSON
    'Kickstart Metadata' => { attribute: 'kickstart_meta', type: 'hash' },
    # Strip braces and parse as CSV
    'Management Classes' => { attribute: 'mgmt_classes', type: 'array' },
    'Management Parameters' => { attribute: 'mgmt_parameters', type: 'string' },
    # Strip braces and parse as CSV
    'Name Servers' => { attribute: 'name_servers', type: 'array' },
    'Name Servers Search Path' => { attribute: 'name_servers_search_path', type: 'string' },
    # Strip braces and parse as CSV
    'Owners' => { attribute: 'owners', type: 'array' },
    'Parent Profile' => { attribute: 'parent_profile', type: 'string' },
    'Internal Proxy' => { attribute: 'internal_proxy', type: 'string' },
    'Red Hat Management Key' => { attribute: 'redhat_management_key', type: 'string' },
    'Red Hat Management Server' => { attribute: 'redhat_management_server', type: 'string' },
    'Repos' => { attribute: 'repos', type: 'array' },
    'Server Override' => { attribute: 'server_override', type: 'string' },
    # Parse as JSON
    'Template Files' => { attribute: 'template_files', type: 'hash' },
    'Virt Auto Boot' => { attribute: 'auto_boot', type: 'string' },
    'Virt Bridge' => { attribute: 'bridge', type: 'string' },
    'Virt CPUs' => { attribute: 'cpus', type: 'string' },
    'Virt Disk Driver Type' => { attribute: 'disk_driver_type', type: 'string' },
    'Virt File Size (GB)' => { attribute: 'disk_size', type: 'string' },
    'Virt Path' => { attribute: 'disk_path', type: 'string' },
    'Virt RAM (MB)' => { attribute: 'ram', type: 'string' },
    'Virt Type' => { attribute: 'virtualization_type', type: 'string' }
  }.freeze
end

def load_cobbler_profile # rubocop:disable Metrics/AbcSize
  if false
    command = "cobbler profile report --name='#{name}'"
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

  retval = {}
  config_file = ::File.join('/var/lib/cobbler/config/profiles.d/', name, '.json')
  if ::File.exist?(config_file)
    retval = JSON.parse(::File.read(config_file))
  else
    Chef::Log.error("Configuration file #{config_file} needed to load the existing profile does not exist")
  end

  retval
end

#--------------------------------------------------------------------------------
# OUTDATED CODE / NOT USED
def field_value(input, field)
  value = nil
  input.each do |line_item|
    line_item.chomp!
    parts = line_item.split(':')
    parts[0].strip!
    parts[1].strip!

    # Skip the line read from the Cobbler output if the field name in the line is not part of our property set.
    next unless PROFILE_FIELDS.key?(parts[0])

    # Get the attribute / property name used in our Hash constant so it can be compared to the requested 'field'; if
    # they match, then grab the value from the output and return it.
    next unless PROFILE_FIELDS[parts[0]][:attribute] == field

    # In case the value to the right of the first colon contained colons itself (and thus resulted in multiple array
    # parts), rejoin the array while eliminating the first part (which is the field name). e.g. this value:
    #
    # "Kernel Options                 : {'interface': 'auto'}"
    #
    # when split(':') will result in three array elements:
    #
    # - "Kernel Options                 "
    # - " {'interface'"
    # - " 'auto'}"
    assembled_value = parts[1..-1].join(':').strip
    value = convert_field_value(PROFILE_FIELDS[parts[0]][:type], assembled_value)
  end

  value
end

def convert_field_value(field_type, field_value) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
  retval = nil

  case field_type
  when 'hash'
    # Parse as JSON
    retval = JSON.parse(field_value.)
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
# END OUTDATED CODE
#--------------------------------------------------------------------------------

action_class do
  #------------------------------------------------------------
  # Defines the allowable architectures, used for input validation.
  # TODO: Move the list of architectures and breeds to a helper method so they are globally accessible.
  #------------------------------------------------------------
  def architectures
    %w[i386 x86_64 ia64 ppc ppc64 ppc64le s390 arm noarch src]
  end

  #------------------------------------------------------------
  # Defines the allowable breed for the profile type, used for input validation.
  #------------------------------------------------------------
  def breeds
    %w[rsync rhn yum apt wget]
  end

  #------------------------------------------------------------
  # Validates that the provided inputs do not include any reserved words or separate characters
  #------------------------------------------------------------
  def validate_input
    # TODO: Add validation
    true
  end

  require 'etc'
  require 'digest'
end
