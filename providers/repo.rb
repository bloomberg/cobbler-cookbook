# rubocop:disable Metrics/AbcSize

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
    Chef::Log.error "A repository named #{@current_resource.name} already exists. Not creating."
    # Use this to raise exceptions that stop a chef run.
    # raise "Our file already exists."
  else
    # Converge our node
    converge_by("Creating Cobbler repository #{@new_resource.base_name}") do
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
    converge_by("Deleting Cobbler repository #{@new_resource.base_name}") do
      resp = delete
      @new_resource.updated_by_last_action(resp)
    end
  else
    Chef::Log.error "The repository #{@new_resource.base_name} does not exist, nothing was deleted."
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
    @current_resource = load_repo(@new_resource.base_name)
    @current_resource.exists = true
  else
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
# Defines the allowable breed for the repository type, used for input validation.
#------------------------------------------------------------
def breeds
  %w(rsync yum apt rhn wget)
end

#------------------------------------------------------------
# Queries Cobbler to determine if a specific repository exists.
#------------------------------------------------------------
def exists?(repo_name = nil)
  Chef::Log.debug("Checking if repo '#{repo_name}' already exists")
  if repo_name.nil?
    false
  else
    find_command = "cobbler repo find --name=#{repo_name} | grep '#{repo_name}'"
    Chef::Log.debug("Searching for '#{repo_name}' using #{find_command}")
    find = Mixlib::ShellOut.new(find_command)
    find.run_command
    Chef::Log.debug("Standard out from 'repo find' is #{find.stdout.chomp}")
    (find.stdout.chomp == repo_name)
  end
end

#------------------------------------------------------------
# Creates a new Cobbler repository if a repository with the same name does not already exist.
#------------------------------------------------------------
def create
  unless architectures.include?(@new_resource.architecture)
    raise "The specified architecture (#{@new_resource.architecture}) is not one of #{architectures.join(',')}"
  end

  unless breeds.include?(@new_resource.os_breed)
    raise "The specified breed (#{@new_resource.os_breed}) is not one of #{breeds.join(',')}"
  end

  # Setup command with known required attributes
  repo_command = "cobbler repo add --name=#{@new_resource.base_name}"
  repo_command = "#{repo_command} --owners='#{@new_resource.owners.join(',')}'"
  repo_command = "#{repo_command} --arch=#{@new_resource.architecture} --breed=#{@new_resource.os_breed}"
  repo_command = "#{repo_command} --mirror=#{@new_resource.mirror_url}"
  repo_command = "#{repo_command} --keep-updated=#{@new_resource.keep_updated}"
  repo_command = "#{repo_command} --mirror-locally=#{@new_resource.mirror_locally}"

  # Parameters that are not required, add them only if they are specified.
  unless @new_resource.comment.nil?
    repo_command = "#{repo_command} --comment='#{@new_resource.comment}'"
  end

  # Only applicable for YUM based repositories
  unless @new_resource.rpm_list.nil? || @new_resource.os_breed != 'yum'
    repo_command = "#{repo_command} --rpm-list='#{@new_resource.rpm_list.join(',')}'"
  end

  unless @new_resource.proxy_url.nil?
    repo_command = "#{repo_command} --proxy='#{@new_resource.proxy_url}'"
  end

  unless @new_resource.apt_components.nil?
    repo_command = "#{repo_command} --apt-components=#{@new_resource.apt_components.join(',')}"
  end

  unless @new_resource.apt_dist_names.nil?
    repo_command = "#{repo_command} --apt-dists='#{@new_resource.apt_dist_names}'"
  end

  unless @new_resource.createrepo_flags.nil?
    repo_command = "#{repo_command} --createrepo-flags='#{@new_resource.createrepo_flags}'"
  end

  unless @new_resource.env_variables.nil?
    repo_command = "#{repo_command} --environment=#{@new_resource.env_variables.join(',')}"
  end

  unless @new_resource.priority.nil?
    repo_command = "#{repo_command} --priority='#{@new_resource.priority}'"
  end

  unless @new_resource.yum_options.nil?
    repo_command = "#{repo_command} --yumopts='#{@new_resource.yum_options}'"
  end

  repo_command = "#{repo_command} --clobber" if @new_resource.clobber

  Chef::Log.debug "Will add new repository using the command '#{repo_command}'"
  Chef::Log.info "Adding the #{@new_resource.base_name} repository"
  bash "#{@new_resource.base_name}-cobbler-repo-add" do
    code <<-CODE
      #{repo_command}
    CODE
    umask 0o0002
  end

  # Return the state of the repository; if it does not exist, nothing was added.
  exists?(@new_resource.base_name)
end

#------------------------------------------------------------
# Deletes an existing Cobbler repository.
#------------------------------------------------------------
def delete
  # Setup command with known required attributes. Since only name is required to delete, that is all we're using.
  repo_command = "cobbler repo remove --name=#{@current_resource.base_name}"

  Chef::Log.debug "Will delete existing repository using the command '#{repo_command}'"
  Chef::Log.info "Adding the #{@current_resource.base_name} repository"
  bash "#{@current_resource.base_name}-cobbler-repo-delete" do
    code <<-CODE
      #{repo_command}
    CODE
    umask 0o0002
  end

  # Return the state of the repository; if it does not exist, then it was deleted.
  !exists?(@current_resource.base_name)
end
