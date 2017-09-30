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
def create
  # Setup command with known required attributes. Since only name is required to delete, that is all we're using.
  system_command = "cobbler system add --name=#{@current_resource.base_name}"

  Chef::Log.debug "Will add a new system using the command '#{system_command}'"
  bash "#{@current_resource.base_name}-cobbler-system-create" do
    code <<-CODE
      #{system_command}
    CODE
    umask 0o0002
  end

  # Return the state of the repository; if it does not exist, then it was deleted.
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
