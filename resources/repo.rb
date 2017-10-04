# Base Resource
provides :cobbler_repo
resource_name :cobbler_repo

# Actions that we support.  Must be stated in our provider action :create do.
actions :create, :delete

# Our default action, can be anything.
default_action :create if defined?(default_action)

# Name Space, this is what is passed in "<name>".
property :name, name_attribute: true, kind_of: String, required: true

property :apt_components, kind_of: String, required: false, desired_state: false, default: nil
property :apt_dist_names, kind_of: String, required: false, desired_state: false, default: nil
# Architecture must be one of i386,x86_64,ia64,ppc,ppc64,ppc64le,s390,arm,noarch,src
property :architecture, kind_of: String, required: true, desired_state: false, default: 'x86_64'
property :clobber, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :comment, kind_of: String, required: false, desired_state: false, default: nil
property :createrepo_flags, kind_of: String, required: false, desired_state: false, default: nil
property :env_variables, kind_of: Hash, required: false, desired_state: false, default: nil
property :keep_updated, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :mirror_locally, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: false
property :mirror_url, kind_of: String, required: true, desired_state: false, default: nil
# Must be one of rsync, yum, apt, rhn, wget
property :os_breed, kind_of: String, required: true, desired_state: false, default: 'yum'
property :owners, kind_of: Array, required: true, desired_state: false, default: ['admin']
property :priority, kind_of: Integer, required: false, desired_state: false, default: 99
property :proxy_url, kind_of: String, required: false, desired_state: false, default: nil
property :rpm_list, kind_of: Array, required: false, desired_state: false, default: nil
property :yum_options, kind_of: Hash, required: false, desired_state: false, default: nil


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
  if exists?
    # Setup command with known required attributes. Since only name is required to delete, that is all we're using.
    repo_command = "cobbler repo remove --name=#{name}"

    Chef::Log.debug "Will delete existing repository using the command '#{repo_command}'"
    bash "#{name}-cobbler-repo-delete" do
      code repo_command
      umask 0o0002
    end
  end
end

load_current_value do
  if exists?
    data = load_cobbler_repo

    # TODO: Use the 'send' feature / function to programatically (and dynamically) do this.
    apt_components data['apt_components']
    apt_dist_names data['apt_dists']
    architecture data['arch']
    comment data['comment']
    createrepo_flags data['createrepo_flags']
    env_variables data['environment']
    keep_updated data['keep_updated'].nil? || data['keep_updated'] == 'false' ? false : true
    mirror_locally data['mirror_locally'].nil? || data['mirror_locally'] == 'false' ? false : true
    mirror_url data['mirror']
    os_breed data['breed']
    owners data['owners']
    priority data['priority']
    proxy_url data['proxy']
    rpm_list data['rpm_list']
    yum_options data['yumopts']
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

def load_cobbler_repo # rubocop:disable Metrics/AbcSize
  retval = {}
  config_file = ::File.join('/var/lib/cobbler/config/repos.d/', "#{name}.json")
  if ::File.exist?(config_file)
    retval = JSON.parse(::File.read(config_file))
  else
    Chef::Log.error("Configuration file #{config_file} needed to load the existing repo does not exist")
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
