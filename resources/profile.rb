# Base Resource
provides :cobbler_profile
resource_name :cobbler_profile

actions :create, :delete

default_action :create

property :name, name_attribute: true, kind_of: String, required: true

property :auto_boot, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: nil
property :boot_files, kind_of: Hash, required: false, desired_state: false, default: nil
property :bridge, kind_of: String, required: false, desired_state: false, default: nil
property :comment, kind_of: String, required: false, desired_state: false, default: nil
property :cpus, kind_of: Integer, required: false, desired_state: false, default: 0
property :dhcp_tag, kind_of: String, required: false, desired_state: false, default: nil
property :disk_driver_type, kind_of: String, required: false, desired_state: false, default: nil
property :disk_path, kind_of: String, required: false, desired_state: false, default: nil
property :disk_size, kind_of: Integer, required: false, desired_state: false, default: 16
property :distro, kind_of: String, required: false, desired_state: false, default: nil
property :enable_gpxe, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :enable_pxe_menu, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :fetchable_files, kind_of: Hash, required: false, desired_state: false, default: nil
property :internal_proxy, kind_of: String, required: false, desired_state: false, default: nil
property :kernel_options, kind_of: Hash, default: { interface: 'auto' }
property :kernel_options_postinstall, kind_of: Hash, default: {}
property :kickstart, kind_of: String, required: false, desired_state: false, default: nil
property :kickstart_meta, kind_of: Hash, required: false, desired_state: false, default: {}
property :mgmt_classes, kind_of: Array, required: false, desired_state: false, default: []
property :mgmt_parameters, kind_of: String, required: false, desired_state: false, default: nil
property :name_servers, kind_of: Array, required: false, desired_state: false, default: []
property :name_servers_search_path, kind_of: Array, required: false, desired_state: false, default: []
property :owners, kind_of: Array, required: false, desired_state: false, default: ['admin']
property :parent_profile, kind_of: String, required: false, desired_state: false, default: nil
property :ram, kind_of: Integer, required: false, desired_state: false, default: 1024
property :redhat_management_key, kind_of: String, required: false, desired_state: false, default: nil
property :redhat_management_server, kind_of: String, required: false, desired_state: false, default: nil
property :repos, kind_of: Array, required: false, desired_state: false, default: nil
property :server_override, kind_of: String, required: false, desired_state: false, default: nil
property :template_files, kind_of: Hash, required: false, desired_state: false, default: {}
property :template_remote_kickstarts, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :virtualization_type, kind_of: String, required: false, desired_state: false, default: nil

# This is a standard ruby accessor, use this to set flags for current state.
attr_accessor :exists
attr_accessor :dependencies

action :create do
  # TODO: Add check to ensure that the specified distro exists.
  command = "cobbler profile add --name='#{new_resource.name}'"
  command = "#{command} --distro='#{new_resource.distro}'"
  command = "#{command} --kickstart='#{new_resource.kickstart}'"

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
  if exists?
    profile_command = "cobbler profile remove --name='#{name}'"
    bash "#{new_resource.name}-cobbler-profile-delete" do
      code profile_command
      notifies :run, 'bash[cobbler-sync]', :delayed
    end

    kickstart_file = "/var/lib/cobbler/kickstarts/#{name}"
    file kickstart_file do
      action :delete
    end
  end
end

load_current_value do
  if exists?
    data = load_cobbler_profile

    # Other (immutable) fields to consider:
    # - mtime
    # - ctime
    # - uid
    #
    # Missing items
    # - template_remote_kickstarts

    # TODO: Use the 'send' feature / function to programatically (and dynamically) do this.
    auto_boot data['virt_auto_boot'].nil? || data['virt_auto_boot'] == 0 ? false : true
    boot_files data['boot_files']
    bridge data['virt_bridge']
    comment data['comment']
    cpus data['virt_cpus']
    dhcp_tag data['dhcp_tag']
    disk_driver_type data['virt_disk_driver']
    disk_path data['virt_path']
    disk_size data['virt_file_size']
    distro data['distro']
    enable_gpxe data['enable_gpxe'].nil? || data['virt_auto_boot'] == 0 ? false : true
    enable_pxe_menu data['enable_menu'].nil? || data['virt_auto_boot'] == 0 ? false : true
    fetchable_files data['fetchable_files']
    internal_proxy data['proxy']
    kernel_options data['kernel_options']
    kernel_options_postinstall data['kernel_options_post']
    kickstart data['kickstart']
    kickstart_meta data['ks_meta']
    mgmt_classes data['mgmt_classes']
    mgmt_parameters data['mgmt_parameters']
    name_servers data['name_servers']
    name_servers_search_path data['name_servers_search']
    owners data['owners']
    parent_profile data['parent']
    ram data['virt_ram']
    redhat_management_key data['redhat_management_key']
    redhat_management_server data['redhat_management_server']
    repos data['repos']
    server_override data['server']
    template_files data['template_files']
    template_remote_kickstarts data['template_remote_kickstarts'].nil? || data['template_remote_kickstarts'] == 0 ?
                                false : true
    virtualization_type data['virt_type']
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

def load_cobbler_profile # rubocop:disable Metrics/AbcSize
  retval = {}
  config_file = ::File.join('/var/lib/cobbler/config/profiles.d/', "#{name}.json")
  if ::File.exist?(config_file)
    retval = JSON.parse(::File.read(config_file))
  else
    Chef::Log.error("Configuration file #{config_file} needed to load the existing profile does not exist")
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
