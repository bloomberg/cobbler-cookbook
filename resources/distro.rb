# Base Resource
provides :cobbler_distro
resource_name :cobbler_distro

# Actions that we support.  Must be stated in our provider action :create do.
actions :create, :delete

# Our default action, can be anything.
default_action :create if defined?(default_action)

# Name Space, this is what is passed in "<name>".
property :name, name_attribute: true, kind_of: String, required: true
property :owners, kind_of: Array, required: true, desired_state: false, default: ['admin']
property :kernel, kind_of: String, required: true, desired_state: false, default: nil
property :initrd, kind_of: String, required: true, desired_state: false, default: nil
# Valid options i386,x86_64,ia64,ppc,ppc64,ppc64le,s390,arm
property :architecture, kind_of: String, required: true, desired_state: false, default: nil
# Valid options
property :os_breed, kind_of: String, required: true, desired_state: false, default: nil
# Valid options
property :os_version, kind_of: String, required: true, desired_state: false, default: nil

property :comment, kind_of: String, required: false, desired_state: false, default: nil
property :ctime, kind_of: String, required: false, desired_state: false, default: nil
property :mtime, kind_of: String, required: false, desired_state: false, default: nil
property :uid, kind_of: String, required: false, desired_state: false, default: nil
property :kernel_options, kind_of: Hash, required: false, desired_state: false, default: nil
property :kernel_options_postinstall, kind_of: Hash, required: false, desired_state: false, default: nil
property :kickstart_meta, kind_of: Hash, required: false, desired_state: false, default: nil
property :source_repos, kind_of: Array, required: false, desired_state: false, default: nil
property :depth, kind_of: String, required: false, desired_state: false, default: nil
property :tree_build_time, kind_of: String, required: false, desired_state: false, default: nil
property :mgmt_classes, kind_of: String, required: false, desired_state: false, default: nil
property :boot_files, kind_of: Array, required: false, desired_state: false, default: []
property :fetchable_files, kind_of: Hash, required: false, desired_state: false, default: nil
property :template_files, kind_of: Hash, required: false, desired_state: false, default: nil
property :redhat_management_key, kind_of: String, required: false, desired_state: false, default: nil
property :redhat_management_server, kind_of: String, required: false, desired_state: false, default: nil
property :clobber, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :in_place, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false

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

    distro_command = "#{distro_command} --depth='#{new_resource.depth}'" unless new_resource.depth.nil?

    unless new_resource.tree_build_time.nil?
      distro_command = "#{distro_command} --tree-build-time='#{new_resource.tree_build_time}'"
    end

    unless new_resource.mgmt_classes.nil?
      distro_command = "#{distro_command} --mgmt-classes='#{new_resource.mgmt_classes}'"
    end

    boot_files = []
    new_resource.boot_files.each do |ent|
      ent.each_pair do |k, v|
        boot_files << "'#{k}'='#{v}'"
      end
    end
    distro_command = "#{distro_command} --boot-files=#{boot_files.join(',')}" unless new_resource.boot_files.nil?

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
  if exists?(current_resource.name)
    # Attempting to delete a distro on which one or more profiles depends will result in an error such as:
    # 'removal would orphan profile: something'
    if dependencies?
      Chef::Log.error("Cannot remove the distro #{name} because it has dependencies")
    else
      # Setup command with known required attributes. Since only name is required to delete, that is all we're using.
      distro_command = "cobbler distro remove --name=#{name}"

      Chef::Log.debug "Will delete existing OS distro using the command '#{distro_command}'"
      bash "#{@current_resource.name}-cobbler-distro-remove" do
        code <<-CODE
          #{distro_command}
        CODE
        umask 0o0002
      end
    end
  end
end

load_current_value do
  if exists?
    data = load_cobbler_distro

    # TODO: Use the 'send' feature / function to programatically (and dynamically) do this.
    name field_value(data, 'name')
    owners field_value(data, 'owners')
    kernel field_value(data, 'kernel')
    initrd field_value(data, 'initrd')
    architecture field_value(data, 'architecture')
    os_breed field_value(data, 'os_breed')
    os_version field_value(data, 'os_version')
    comment field_value(data, 'comment')
    ctime field_value(data, 'ctime')
    mtime field_value(data, 'mtime')
    uid field_value(data, 'uid')
    kernel_options field_value(data, 'kernel_options')
    kernel_options_postinstall field_value(data, 'kernel_options_postinstall')
    kickstart_meta field_value(data, 'kickstart_meta')
    source_repos field_value(data, 'source_repos')
    depth field_value(data, 'depth')
    tree_build_time field_value(data, 'tree_build_time')
    mgmt_classes field_value(data, 'mgmt_classes')
    boot_files field_value(data, 'boot_files')
    fetchable_files field_value(data, 'fetchable_files')
    template_files field_value(data, 'template_files')
    redhat_management_key field_value(data, 'redhat_management_key')
    redhat_management_server field_value(data, 'redhat_management_server')
    clobber field_value(data, 'clobber')
    in_place field_value(data, 'in_place')
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
  deps_command = "cobbler profile find --distro='#{@current_resource.name}' | wc -l"

  Chef::Log.debug "Searching for profiles with a dependency on the distro '#{@current_resource.name}'"
  find = Mixlib::ShellOut.new(deps_command)
  find.run_command

  Chef::Log.debug("Standard out from 'profile file --distro=#{@current_resource.name}' is #{find.stdout.chomp}")
  # True if the value in stdout matches our distro_name
  result = find.stdout.chomp.to_i

  result.positive?
end

unless defined? DISTRO_FIELDS
  DISTRO_FIELDS = {
    'Name' => { attribute: 'name', type: 'string' },
    'Architecture' => { attribute: 'architecture', type: 'string' },
    # Parse as JSON
    'TFTP Boot Files' => { attribute: 'boot_files', type: 'array' },
    'Breed' => { attribute: 'os_breed', type: 'string' },
    'Comment' => { attribute: 'comment', type: 'string' },
    # Parse as JSON
    'Fetchable Files' => { attribute: 'fetchable_files', type: 'hash' },
    'Initrd' => { attribute: 'initrd', type: 'string' },
    'Kernel' => { attribute: 'kernel', type: 'string' },
    # Parse as JSON
    'Kernel Options' => { attribute: 'kernel_options', type: 'hash' },
    # Parse as JSON
    'Kernel Options (Post Install)' => { attribute: 'kernel_options_postinstall', type: 'hash' },
    # Parse as JSON
    'Kickstart Metadata' => { attribute: 'kickstart_meta', type: 'hash' },
    # Strip braces and parse as CSV
    'Management Classes' => { attribute: 'mgmt_classes', type: 'array' },
    'OS Version' => { attribute: 'os_version', type: 'string' },
    # Strip braces and parse as CSV
    'Owners' => { attribute: 'owners', type: 'array' },
    'Red Hat Management Key' => { attribute: 'redhat_management_key', type: 'string' },
    'Red Hat Management Server' => { attribute: 'redhat_management_server', type: 'string' },
    # Parse as JSON
    'Template Files' => { attribute: 'template_files', type: 'hash' }
  }.freeze
end

def load_cobbler_distro # rubocop:disable Metrics/AbcSize
  command = "cobbler distro report --name='#{name}'"
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
    next unless DISTRO_FIELDS.key?(parts[0])

    # Get the attribute / property name used in our Hash constant so it can be compared to the requested 'field'; if
    # they match, then grab the value from the output and return it.
    next unless DISTRO_FIELDS[parts[0]][:attribute] == field
    value = convert_field_value(DISTRO_FIELDS[parts[0]][:type], parts[1])
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
  # Defines the allowable breed for the distro type, used for input validation.
  #------------------------------------------------------------
  def breeds
    %w[suse redhat windows xen generic unix freebsd ubuntu nexenta debian vmware]
  end

  #------------------------------------------------------------
  # Validates that the provided inputs do not include any reserved words or separate characters
  #------------------------------------------------------------
  def validate_input
    # Check if any restricted words are present
    bare_words = node['cobblerd']['distro']['reserved_words']['bare_words']
    separators = node['cobblerd']['distro']['reserved_words']['separators']
    arch = node['cobblerd']['distro']['reserved_words']['arch']
    strings_caught = bare_words.select { |word| word if new_resource.name.include?(word) }
    all_strings = separators.collect do |sep|
      arch.collect do |a|
        sep + a if new_resource.name.include?(sep + a)
      end
    end
    strings_caught += all_strings.flatten.select { |s| s }

    unless strings_caught.empty?
      msg = "Invalid cobbler distro name #{new_resource.name} -- "
      msg += "it would be changed by Cobbler\nContentious strings: #{strings_caught.join(', ')}"
      Chef::Application.fatal!(msg)
    end

    unless new_resource.nil? || breeds.include?(new_resource.os_breed)
      msg = "Invalid cobbler distro breed #{new_resource.os_breed} -- "
      msg += "must be one of #{breeds.join(',')}"
      Chef::Application.fatal!(msg)
    end
  end

  require 'etc'
  require 'digest'
end
