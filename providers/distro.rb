# rubocop:disable Style/GuardClause,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity

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
  if @current_resource.exists # Only create if it does not exist.
    Chef::Log.warn "An OS distro named #{@current_resource.name} already exists. Not creating."
    # Use this to raise exceptions that stop a chef run.
    # raise "Our file already exists."
  else
    # Converge our node
    converge_by("Creating Cobbler OS distro #{@new_resource.base_name}") do
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
  if @current_resource.exists # Only delete if it exists.
    # Converge our node
    Chef::Log.info("Distribution #{@current_resource.base_name} exists and will be removed")
    converge_by("Deleting Cobbler OS distro #{@new_resource.base_name}") do
      resp = delete
      # We set our updated flag based on the resource we utilized.
      @new_resource.updated_by_last_action(resp)
    end
  else
    Chef::Log.warn "The OS distro #{@new_resource.base_name} does not exist, nothing was deleted."
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
    Chef::Log.debug("New resource with name #{@new_resource.base_name} already exists")
    @current_resource = load_distro(@new_resource.base_name)
    @current_resource.exists = true
  else
    Chef::Log.debug("New resource with name #{@new_resource.base_name} does not exist")
    @current_resource = @new_resource.clone
    @current_resource.exists = false
  end
end

#------------------------------------------------------------
# Defines the allowable architectures, used for input validation.
# TODO: Move the list of architectures and breeds to a helper method so they are globally accessible.
#------------------------------------------------------------
def architectures
  %w(i386 x86_64 ia64 ppc ppc64 ppc64le s390 arm noarch src)
end

#------------------------------------------------------------
# Defines the allowable breed, used for input validation.
#------------------------------------------------------------
def breeds
  %w(suse redhat windows xen generic unix freebsd ubuntu nexenta debian vmware)
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
      sep + a if @new_resource.name.include?(sep + a)
    end
  end
  strings_caught += all_strings.flatten.select { |s| s }

  unless strings_caught.empty?
    msg = "Invalid cobbler image name #{new_resource.name} -- "
    msg += "it would be changed by Cobbler\nContentious strings: #{strings_caught.join(', ')}"
    Chef::Application.fatal!(msg)
  end
end

#------------------------------------------------------------
# Queries Cobbler to determine if a specific distribution exists.
#------------------------------------------------------------
def exists?(distro_name = nil)
  Chef::Log.debug("Checking if distro '#{distro_name}' already exists")
  if distro_name.nil?
    false
  else
    find_command = "cobbler distro find --name=#{distro_name} | grep '#{distro_name}'"
    Chef::Log.debug("Searching for '#{distro_name}' using #{find_command}")
    find = Mixlib::ShellOut.new(find_command)
    find.run_command
    Chef::Log.debug("Standard out from 'distro find' is #{find.stdout.chomp}")
    # True if the value in stdout matches our distro_name
    (find.stdout.chomp == distro_name)
  end
end

#------------------------------------------------------------
# Creates a new Cobbler distro if a distro with the same name does not already exist.
#------------------------------------------------------------
def create
  unless architectures.include?(@new_resource.architecture)
    raise "The specified architecture (#{@new_resource.architecture}) is not one of #{architectures.join(',')}"
  end

  unless breeds.include?(@new_resource.os_breed)
    raise "The specified breed (#{@new_resource.os_breed}) is not one of #{breeds.join(',')}"
  end

  # TODO: Create a command builder library.
  # Setup command with known required attributes
  distro_command = "cobbler distro add --name=#{@new_resource.base_name}"
  distro_command = "#{distro_command} --owners='#{@new_resource.owners.join(',')}'"
  distro_command = "#{distro_command} --kernel=#{@new_resource.kernel} --initrd=#{@new_resource.initrd}"
  distro_command = "#{distro_command} --arch=#{@new_resource.architecture}"
  distro_command = "#{distro_command} --breed=#{@new_resource.os_breed}"
  distro_command = "#{distro_command} --os-version=#{@new_resource.os_version}"
  distro_command = "#{distro_command} --in-place" if @new_resource.in_place

  # Parameters that are not required, add them only if they are specified.
  distro_command = "#{distro_command} --comment='#{@new_resource.comment}'" unless @new_resource.comment.nil?
  distro_command = "#{distro_command} --ctime='#{@new_resource.ctime}'" unless @new_resource.ctime.nil?
  distro_command = "#{distro_command} --mtime=#{@new_resource.mtime.join(',')}" unless @new_resource.mtime.nil?
  distro_command = "#{distro_command} --uid='#{@new_resource.uid}'" unless @new_resource.uid.nil?

  # Using this style to avoid Rubocop 'Metrics/LineLength' complaint
  unless @new_resource.kernel_options.nil?
    distro_command = "#{distro_command} --kopts='#{@new_resource.kernel_options.join(',')}'"
  end

  unless @new_resource.kernel_options_postinstall.nil?
    distro_command = "#{distro_command} --kopts-post='#{@new_resource.kernel_options_postinstall.join(',')}'"
  end

  unless @new_resource.kickstart_meta.nil?
    distro_command = "#{distro_command} --kickstart_meta='#{@new_resource.kickstart_meta..join(',')}'"
  end

  unless @new_resource.source_repos.nil?
    distro_command = "#{distro_command} --source-repos='#{@new_resource.source_repos.join(',')}'"
  end

  distro_command = "#{distro_command} --depth='#{@new_resource.depth}'" unless @new_resource.depth.nil?

  unless @new_resource.tree_build_time.nil?
    distro_command = "#{distro_command} --tree-build-time='#{@new_resource.tree_build_time}'"
  end

  unless @new_resource.mgmt_classes.nil?
    distro_command = "#{distro_command} --mgmt-classes='#{@new_resource.mgmt_classes}'"
  end

  boot_files = []
  @new_resource.boot_files.each do |ent|
    ent.each_pair do |k, v|
      boot_files << "'#{k}'='#{v}'"
    end
  end
  distro_command = "#{distro_command} --boot-files=#{boot_files.join(',')}" unless @new_resource.boot_files.nil?

  unless @new_resource.fetchable_files.nil?
    distro_command = "#{distro_command} --fetchable-files='#{@new_resource.fetchable_files}'"
  end

  unless @new_resource.template_files.nil?
    distro_command = "#{distro_command} --template-files='#{@new_resource.template_files}'"
  end

  unless @new_resource.redhat_management_key.nil?
    distro_command = "#{distro_command} --redhat-management-key='#{@new_resource.redhat_management_key}'"
  end

  unless @new_resource.redhat_management_server.nil?
    distro_command = "#{distro_command} --redhat-management-server='#{@new_resource.redhat_management_server}'"
  end
  distro_command = "#{distro_command} --clobber" if @new_resource.clobber

  Chef::Log.debug "Will add new OS distro using the command '#{distro_command}'"
  bash "#{@new_resource.base_name}-cobbler-distro-add" do
    code <<-CODE
      #{distro_command}
    CODE
    umask 0o0002
  end

  # Return the state of the distro; if it does not exist, nothing was added.
  exists?(@new_resource.base_name)
end

#------------------------------------------------------------
# Deletes an existing Cobbler distro.
#------------------------------------------------------------
def delete
  # Attempting to delete a distro on which one or more profiles depends will result in an error such as:
  # 'removal would orphan profile: something'
  if dependencies?
    Chef::Log.error("Cannot remove the distro #{@current_resource.base_name} because it has dependencies")
  else
    # Setup command with known required attributes. Since only name is required to delete, that is all we're using.
    distro_command = "cobbler distro remove --name=#{@current_resource.base_name}"

    Chef::Log.debug "Will delete existing OS distro using the command '#{distro_command}'"
    bash "#{@current_resource.base_name}-cobbler-distro-remove" do
      code <<-CODE
        #{distro_command}
      CODE
      umask 0o0002
    end
  end

  # Return the state of the distro; if it does not exist, then it was deleted.
  !exists?(@current_resource.base_name)
end

#------------------------------------------------------------
# Determines if any other objects have dependencies on the current resource. Used when deleting existing resources.
#------------------------------------------------------------
def dependencies?
  deps_command = "cobbler profile find --distro='#{@current_resource.base_name}' | wc -l"

  Chef::Log.debug "Searching for profiles with a dependency on the distro '#{@current_resource.base_name}'"
  find = Mixlib::ShellOut.new(deps_command)
  find.run_command

  Chef::Log.debug("Standard out from 'profile file --distro=#{@current_resource.base_name}' is #{find.stdout.chomp}")
  # True if the value in stdout matches our distro_name
  result = find.stdout.chomp.to_i

  (result > 0)
end
