# Base Resource
provides :cobbler_repo
resource_name :cobbler_repo

# Actions that we support.  Must be stated in our provider action :create do.
actions :create, :delete

# Our default action, can be anything.
default_action :create if defined?(default_action)

# Name Space, this is what is passed in "<name>".
property :name, name_attribute: true, kind_of: String, required: true
property :owners, kind_of: Array, required: true, desired_state: false, default: ['admin']
# Architecture must be one of i386,x86_64,ia64,ppc,ppc64,ppc64le,s390,arm,noarch,src
property :architecture, kind_of: String, required: true, desired_state: false, default: 'x86_64'
# Must be one of rsync, yum, apt, rhn, wget
property :os_breed, kind_of: String, required: true, desired_state: false, default: 'yum'
property :mirror_url, kind_of: String, required: true, desired_state: false, default: nil
property :comment, kind_of: String, required: false, desired_state: false, default: nil
property :keep_updated, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :rpm_list, kind_of: Array, required: false, desired_state: false, default: nil
property :proxy_url, kind_of: String, required: false, desired_state: false, default: nil
property :apt_components, kind_of: String, required: false, desired_state: false, default: nil
property :apt_dist_names, kind_of: String, required: false, desired_state: false, default: nil
property :createrepo_flags, kind_of: String, required: false, desired_state: false, default: nil
property :env_variables, kind_of: Hash, required: false, desired_state: false, default: nil
property :mirror_locally, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :priority, kind_of: String, required: false, desired_state: false, default: '99'
property :yum_options, kind_of: Hash, required: false, desired_state: false, default: nil
property :clobber, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false

# This is a standard ruby accessor, use this to set flags for current state.
attr_accessor :exists

action :create do
  validate_input

  # Setup command with known required attributes
  repo_command = "cobbler repo add --name=#{new_resource.name}"
  repo_command = "#{repo_command} --owners='#{new_resource.owners.join(',')}'"
  repo_command = "#{repo_command} --arch=#{new_resource.architecture} --breed=#{new_resource.os_breed}"
  repo_command = "#{repo_command} --mirror=#{new_resource.mirror_url}"
  repo_command = "#{repo_command} --keep-updated=#{new_resource.keep_updated}"
  repo_command = "#{repo_command} --mirror-locally=#{new_resource.mirror_locally}"

  # Parameters that are not required, add them only if they are specified.
  unless new_resource.comment.nil?
    repo_command = "#{repo_command} --comment='#{new_resource.comment}'"
  end

  # Only applicable for YUM based repositories
  unless new_resource.rpm_list.nil? || new_resource.os_breed != 'yum'
    repo_command = "#{repo_command} --rpm-list='#{new_resource.rpm_list.join(',')}'"
  end

  unless new_resource.proxy_url.nil?
    repo_command = "#{repo_command} --proxy='#{new_resource.proxy_url}'"
  end

  unless new_resource.apt_components.nil?
    repo_command = "#{repo_command} --apt-components=#{new_resource.apt_components.join(',')}"
  end

  unless new_resource.apt_dist_names.nil?
    repo_command = "#{repo_command} --apt-dists='#{new_resource.apt_dist_names}'"
  end

  unless new_resource.createrepo_flags.nil?
    repo_command = "#{repo_command} --createrepo-flags='#{new_resource.createrepo_flags}'"
  end

  unless new_resource.env_variables.nil?
    repo_command = "#{repo_command} --environment=#{new_resource.env_variables.join(',')}"
  end

  unless new_resource.priority.nil?
    repo_command = "#{repo_command} --priority='#{new_resource.priority}'"
  end

  unless new_resource.yum_options.nil?
    repo_command = "#{repo_command} --yumopts='#{new_resource.yum_options}'"
  end

  repo_command = "#{repo_command} --clobber" if new_resource.clobber

  Chef::Log.debug "Will add new repository using the command '#{repo_command}'"
  Chef::Log.info "Adding the #{new_resource.name} repository"
  bash "#{new_resource.name}-cobbler-repo-create" do
    code <<-CODE
      #{repo_command}
    CODE
    umask 0o0002
  end
end

action :delete do
  # Setup command with known required attributes. Since only name is required to delete, that is all we're using.
  repo_command = "cobbler repo remove --name=#{@current_resource.name}"

  Chef::Log.debug "Will delete existing repository using the command '#{repo_command}'"
  Chef::Log.info "Adding the #{@current_resource.name} repository"
  bash "#{@current_resource.name}-cobbler-repo-delete" do
    code <<-CODE
      #{repo_command}
    CODE
    umask 0o0002
  end
end

load_current_value do
  if exists?
    data = load_cobbler_repo

    # TODO: Use the 'send' feature / function to programatically (and dynamically) do this.
    name field_value(data, 'name')
    owners field_value(data, 'owners')
    architecture field_value(data, 'architecture')
    os_breed field_value(data, 'os_breed')
    mirror_url field_value(data, 'mirror_url')
    comment field_value(data, 'comment')
    keep_updated field_value(data, 'keep_updated')
    rpm_list field_value(data, 'rpm_list')
    proxy_url field_value(data, 'proxy_url')
    apt_components field_value(data, 'apt_components')
    apt_dist_names field_value(data, 'apt_dist_names')
    createrepo_flags field_value(data, 'createrepo_flags')
    env_variables field_value(data, 'env_variables')
    mirror_locally field_value(data, 'mirror_locally')
    priority field_value(data, 'priority')
    yum_options field_value(data, 'yum_options')
    clobber field_value(data, 'clobber')
  end
end

#------------------------------------------------------------
# Queries Cobbler to determine if a specific repo exists.
#------------------------------------------------------------
def exists?
  Chef::Log.debug("Checking if repository '#{name}' already exists")
  if name.nil?
    false
  else
    find_command = "cobbler repo find --name=#{name} | grep '#{name}'"
    Chef::Log.debug("Searching for '#{name}' using #{find_command}")
    find = Mixlib::ShellOut.new(find_command)
    find.run_command
    Chef::Log.debug("Standard out from 'repo find' is #{find.stdout.chomp}")
    # True if the value in stdout matches our name
    (find.stdout.chomp == name)
  end
end

unless defined? REPOSITORY_FIELDS
  REPOSITORY_FIELDS = {
    'Name' => { attribute: 'name', type: 'string' },
    'Owners' => { attribute: 'owners', type: 'array' },
    'Arch' => { attribute: 'architecture', type: 'string' },
    'Breed' => { attribute: 'os_breed', type: 'string' },
    'Mirror' => { attribute: 'mirror_url', type: 'string' },
    'Comment' => { attribute: 'comment', type: 'string' },
    'Keep Updated' => { attribute: 'keep_updated', type: 'boolean' },
    'RPM List' => { attribute: 'rpm_list', type: 'array' },
    'External proxy URL' => { attribute: 'proxy_url', type: 'string' },
    'Apt Components (apt only)' => { attribute: 'apt_components', type: 'string' },
    'Apt Dist Names (apt only)' => { attribute: 'apt_dist_names', type: 'string' },
    'Createrepo Flags' => { attribute: 'createrepo_flags', type: 'string' },
    'Environment Variables' => { attribute: 'env_variables', type: 'hash' },
    'Mirror locally' => { attribute: 'mirror_locally', type: 'boolean' },
    'Priority' => { attribute: 'priority', type: 'string' },
    'Yum Options' => { attribute: 'yum_options', type: 'hash' }
  }.freeze
end

def load_cobbler_repo # rubocop:disable Metrics/AbcSize
  command = "cobbler repo report --name='#{name}'"
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
    next unless REPOSITORY_FIELDS.key?(parts[0])

    # Get the attribute / property name used in our Hash constant so it can be compared to the requested 'field'; if
    # they match, then grab the value from the output and return it.
    next unless REPOSITORY_FIELDS[parts[0]][:attribute] == field
    value = convert_field_value(REPOSITORY_FIELDS[parts[0]][:type], parts[1])
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
  # Defines the allowable breed for the repo type, used for input validation.
  #------------------------------------------------------------
  def breeds
    %w[rsync rhn yum apt wget]
  end

  #------------------------------------------------------------
  # Validates that the provided inputs do not include any reserved words or separate characters
  #------------------------------------------------------------
  def validate_input
    # Check if any restricted words are present
    bare_words = node['cobblerd']['repo']['reserved_words']['bare_words']
    separators = node['cobblerd']['repo']['reserved_words']['separators']
    arch = node['cobblerd']['repo']['reserved_words']['arch']
    strings_caught = bare_words.select { |word| word if new_resource.name.include?(word) }
    all_strings = separators.collect do |sep|
      arch.collect do |a|
        sep + a if new_resource.name.include?(sep + a)
      end
    end
    strings_caught += all_strings.flatten.select { |s| s }

    unless strings_caught.empty?
      msg = "Invalid cobbler repo name #{new_resource.name} -- "
      msg += "it would be changed by Cobbler\nContentious strings: #{strings_caught.join(', ')}"
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
