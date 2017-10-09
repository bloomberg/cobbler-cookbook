# Base Resource
provides :cobbler_distro
resource_name :cobbler_distro

# Actions that we support.  Must be stated in our provider action :create do.
actions :create, :delete

# Our default action, can be anything.
default_action :create if defined?(default_action)

# Name Space, this is what is passed in "<name>".
property :name, name_attribute: true, kind_of: String, required: true
# Valid options i386,x86_64,ia64,ppc,ppc64,ppc64le,s390,arm
property :architecture, kind_of: String, required: true, desired_state: false, default: nil
property :boot_files, kind_of: Hash, required: false, desired_state: false, default: {}
property :clobber, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :comment, kind_of: String, required: false, desired_state: false, default: nil
property :ctime, kind_of: String, required: false, desired_state: false, default: nil
property :depth, kind_of: Integer, required: false, desired_state: false, default: 0
property :fetchable_files, kind_of: Hash, required: false, desired_state: false, default: nil
property :in_place, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :initrd, kind_of: String, required: true, desired_state: false, default: nil
property :kernel, kind_of: String, required: true, desired_state: false, default: nil
property :kernel_options, kind_of: Hash, required: false, desired_state: false, default: nil
property :kernel_options_postinstall, kind_of: Hash, required: false, desired_state: false, default: nil
property :kickstart_meta, kind_of: Hash, required: false, desired_state: false, default: nil
property :mgmt_classes, kind_of: Array, required: false, desired_state: false, default: []
property :mtime, kind_of: String, required: false, desired_state: false, default: nil
property :os_breed, kind_of: String, required: true, desired_state: false, default: nil
property :os_version, kind_of: String, required: true, desired_state: false, default: nil
property :owners, kind_of: Array, required: true, desired_state: false, default: ['admin']
property :redhat_management_key, kind_of: String, required: false, desired_state: false, default: nil
property :redhat_management_server, kind_of: String, required: false, desired_state: false, default: nil
property :source_repos, kind_of: Array, required: false, desired_state: false, default: nil
property :template_files, kind_of: Hash, required: false, desired_state: false, default: nil
property :tree_build_time, kind_of: Float, required: false, desired_state: false, default: 0.0
property :uid, kind_of: String, required: false, desired_state: false, default: nil

# This is a standard ruby accessor, use this to set flags for current state.
attr_accessor :exists
attr_accessor :dependencies

# Create Action
action :create do
  validate_input

  if !exists?
    unless architectures.include?(new_resource.architecture)
      raise "The specified architecture (#{new_resource.architecture}) is not one of #{architectures.join(',')}"
    end

    unless breeds.include?(new_resource.os_breed)
      raise "The specified breed (#{new_resource.os_breed}) is not one of #{breeds.join(',')}"
    end

    # TODO: Create a command builder library.
    # Setup command with known required attributes
    distro_command = "cobbler distro add --name=#{new_resource.name}"
    distro_command = "#{distro_command} --owners='#{new_resource.owners.join(',')}'"
    distro_command = "#{distro_command} --kernel=#{new_resource.kernel} --initrd=#{new_resource.initrd}"
    distro_command = "#{distro_command} --arch=#{new_resource.architecture}"
    distro_command = "#{distro_command} --breed=#{new_resource.os_breed}"
    distro_command = "#{distro_command} --os-version=#{new_resource.os_version}"
    distro_command = "#{distro_command} --in-place" if new_resource.in_place

    # Parameters that are not required, add them only if they are specified.
    distro_command = "#{distro_command} --comment='#{new_resource.comment}'" unless new_resource.comment.nil?
    distro_command = "#{distro_command} --ctime='#{new_resource.ctime}'" unless new_resource.ctime.nil?
    distro_command = "#{distro_command} --mtime=#{new_resource.mtime.join(',')}" unless new_resource.mtime.nil?
    distro_command = "#{distro_command} --uid='#{new_resource.uid}'" unless new_resource.uid.nil?

    # Using this style to avoid Rubocop 'Metrics/LineLength' complaint
    unless new_resource.kernel_options.nil?
      distro_command = "#{distro_command} --kopts='#{new_resource.kernel_options.join(',')}'"
    end

    unless new_resource.kernel_options_postinstall.nil?
      distro_command = "#{distro_command} --kopts-post='#{new_resource.kernel_options_postinstall.join(',')}'"
    end

    unless new_resource.kickstart_meta.nil?
      distro_command = "#{distro_command} --kickstart_meta='#{new_resource.kickstart_meta..join(',')}'"
    end

    unless new_resource.source_repos.nil?
      distro_command = "#{distro_command} --source-repos='#{new_resource.source_repos.join(',')}'"
    end

    unless new_resource.tree_build_time.nil?
      distro_command = "#{distro_command} --tree-build-time='#{new_resource.tree_build_time}'"
    end

    unless new_resource.mgmt_classes.nil?
      distro_command = "#{distro_command} --mgmt-classes='#{new_resource.mgmt_classes.join(',')}'"
    end

    boot_files = []
    new_resource.boot_files.each do |k, v|
      boot_files << "'#{k}'='#{v}'"
    end
    distro_command = "#{distro_command} --boot-files='#{boot_files.join(',')}'" unless new_resource.boot_files.nil?

    unless new_resource.fetchable_files.nil?
      distro_command = "#{distro_command} --fetchable-files='#{new_resource.fetchable_files}'"
    end

    unless new_resource.template_files.nil?
      distro_command = "#{distro_command} --template-files='#{new_resource.template_files}'"
    end

    unless new_resource.redhat_management_key.nil?
      distro_command = "#{distro_command} --redhat-management-key='#{new_resource.redhat_management_key}'"
    end

    unless new_resource.redhat_management_server.nil?
      distro_command = "#{distro_command} --redhat-management-server='#{new_resource.redhat_management_server}'"
    end
    distro_command = "#{distro_command} --clobber" if new_resource.clobber

    Chef::Log.debug "Will add new OS distro using the command '#{distro_command}'"
    bash "#{new_resource.name}-cobbler-distro-add" do
      code distro_command
      umask 0o0002
      notifies :run, 'bash[cobbler-sync]', :delayed
    end
  end

  # TODO: Are these needed and if so, why?
  # cobbler_set_kernel(is_new) if new_resource.kernel
  # cobbler_set_initrd(is_new) if new_resource.initrd
end

action :import do
  validate_input

  # Only import the distro if it doesn't exist
  if !exists?
  end
end

# Delete Action
action :delete do
  if exists?
    # Attempting to delete a distro on which one or more profiles depends will result in an error such as:
    # 'removal would orphan profile: something'
    if dependencies?
      Chef::Log.error("Cannot remove the distro #{name} because it has dependencies")
    else
      # Setup command with known required attributes. Since only name is required to delete, that is all we're using.
      distro_command = "cobbler distro remove --name=#{name}"

      Chef::Log.debug "Will delete existing OS distro using the command '#{distro_command}'"
      bash "#{name}-cobbler-distro-remove" do
        code distro_command
        umask 0o0002
      end
    end
  end
end

load_current_value do
  if exists?
    data = load_cobbler_distro

    # TODO: Use the 'send' feature / function to programatically (and dynamically) do this.
    architecture data['arch']
    boot_files data['boot_files']
    comment data['comment']
    ctime data['ctime'].to_s
    depth data['depth']
    fetchable_files data['fetchable_files']
    initrd data['initrd']
    in_place data['in_place']
    kernel data['kernel']
    kernel_options data['kernel_options']
    kernel_options_postinstall data['kernel_options_post']
    kickstart_meta data['ks_meta']
    mgmt_classes data['mgmt_classes']
    mtime data['mtime'].to_s
    os_breed data['breed']
    os_version data['os_version']
    owners data['owners']
    redhat_management_key data['redhat_management_key']
    redhat_management_server data['redhat_management_server']
    source_repos data['source_repos']
    template_files data['template_files']
    tree_build_time data['tree_build_time'].to_f
    uid data['uid']
  end
end

#------------------------------------------------------------
# Queries Cobbler to determine if a specific distro exists.
#------------------------------------------------------------
def exists?
  Chef::Log.debug("Checking if distro '#{name}' already exists")
  if name.nil?
    false
  else
    find_command = "cobbler distro find --name=#{name} | grep '#{name}'"
    Chef::Log.info("Searching for distro '#{name}' using #{find_command}")
    distro_find = Mixlib::ShellOut.new(find_command)
    distro_find.run_command
    Chef::Log.debug("Standard out from 'distro find' is #{distro_find.stdout.chomp}")

    # True if the value in stdout matches our name
    (distro_find.stdout.chomp == name)
  end
end

#------------------------------------------------------------
# Determines if any other objects have dependencies on the current resource. Used when deleting existing resources.
#------------------------------------------------------------
def dependencies?
  deps_command = "cobbler profile find --distro='#{name}' | wc -l"

  Chef::Log.debug "Searching for profiles with a dependency on the distro '#{name}'"
  find = Mixlib::ShellOut.new(deps_command)
  find.run_command

  Chef::Log.debug("Standard out from 'profile file --distro=#{name}' is #{find.stdout.chomp}")
  # True if the value in stdout matches our distro_name
  result = find.stdout.chomp.to_i

  result.positive?
end

def load_cobbler_distro # rubocop:disable Metrics/AbcSize
  retval = {}
  config_file = ::File.join('/var/lib/cobbler/config/distros.d/', "#{name}.json")
  if ::File.exist?(config_file)
    retval = JSON.parse(::File.read(config_file))
  else
    Chef::Log.error("Configuration file #{config_file} needed to load the existing distro does not exist")
  end

  retval
end

action_class do
  #------------------------------------------------------------
  # Defines the allowable architectures, used for input validation.
  #------------------------------------------------------------
  # Defines the allowable architectures, used for input validation.
  #------------------------------------------------------------
  def architectures
    %w[i386 x86_64 ia64 ppc ppc64 ppc64le s390 arm noarch src]
  end

  #------------------------------------------------------------
  # Defines the allowable breed for the repo type, used for input validation.
  #------------------------------------------------------------
  def breeds
    %w[rsync rhn yum apt wget]
  end

  #------------------------------------------------------------
  # Validates that the provided inputs do not include any reserved words or separate characters
  #------------------------------------------------------------
  def validate_input
    unless new_resource.nil? || architectures.include?(new_resource.architecture)
      msg = "Invalid cobbler repo architecture #{new_resource.architecture} -- "
      msg += "must be one of #{architectures.join(',')}"
      Chef::Application.fatal!(msg)
    end

    unless new_resource.nil? || breeds.include?(new_resource.os_breed)
      msg = "Invalid cobbler repo breed #{new_resource.os_breed} -- "
      msg += "must be one of #{breeds.join(',')}"
      Chef::Application.fatal!(msg)
    end
  end

  require 'etc'
  require 'digest'
end
