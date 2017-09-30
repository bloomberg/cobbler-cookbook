# Base Provider
include Cobbler::Parse

# Notifications are impacted here. If you do delayed notifications, they will be performed at the
# end of the resource run and not at the end of the chef run. You do want to use this as it also
# affects internal resource notifications.
use_inline_resources

# Create Action
action :create do
  # Only create if it does not exist.
  if @current_resource.exists
    Chef::Log.error "A profile named #{@new_resource.name} already exists. Not creating."
    # Use this to raise exceptions that stop a chef run.
    # raise "Our file already exists."
  else
    # Converge our node
    converge_by("Creating a profile #{@new_resource.base_name}.") do
      # TODO: Set the default value of @new_resource.kickstart to source_default only if kickstart is nil
      resp = create
      # We set our updated flag based on the resource we utilized.
      @new_resource.updated_by_last_action(resp)
    end
  end
end

# Delete Action
action :delete do
  # Only delete if it exists.
  if @current_resource.exists
    # Converge our node
    converge_by("Deleting profile #{@new_resource.base_name}.") do
      resp = delete
      @new_resource.updated_by_last_action(resp)
    end
  else
    Chef::Log.error "A profile named #{@new_resource.name} does not exist. Not deleting."
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
    @current_resource = load_profile(@new_resource)
    @current_resource.exists = true
  else
    Chef::Log.debug("New resource with name #{@new_resource.base_name} does not exist")
    @current_resource = @new_resource.clone
    @current_resource.exists = false
  end
end

def breed
  # return breed (e.g. "redhat", "debian", "ubuntu" or "suse")
  @breed ||= cobbler_distro(distro, "Breed")
end

#------------------------------------------------------------
# Queries Cobbler to determine if a specific image exists.
#------------------------------------------------------------
def exists?(profile_name = nil, distro_name = nil)
  if profile_name.nil? || distro_name.nil?
    false
  else
    find_command = "cobbler profile find --name=#{profile_name} --distro=#{distro_name} | grep '#{profile_name}'"
    Chef::Log.info("Searching for '#{profile_name}' using #{find_command}")
    find = Mixlib::ShellOut.new(find_command)
    find.run_command
    Chef::Log.info("Standard out from 'profile find' is #{find.stdout.chomp}")
    (find.stdout.chomp == profile_name)
  end
end

#------------------------------------------------------------
# Builds the command to add a new profile
#------------------------------------------------------------
def cobbler_add_command
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
  command
end

#------------------------------------------------------------
# Creates a new profile if it does not exist.
#------------------------------------------------------------
def create
  template "/var/lib/cobbler/kickstarts/#{new_resource.base_name}" do
    source "#{new_resource.kickstart}.erb"
    action :create
    not_if { new_resource.kickstart.nil? }
  end

  bash "#{new_resource.base_name}-cobbler-profile-add" do
    code cobbler_add_command
    umask 0o0002
    notifies :run, 'bash[cobbler-sync]', :delayed
    not_if { exists?(new_resource.base_name, new_resource.distro) }
  end

  exists?(new_resource.base_name, new_resource.distro)
end

#------------------------------------------------------------
# Deletes an existing profile.
#------------------------------------------------------------
def delete
  bash "#{new_resource.name}-cobbler-profile-delete" do
    code "cobbler profile remove --name='#{new_resource.name}'"
    notifies :run, 'bash[cobbler-sync]', :delayed
    only_if { exists?(new_resource.base_name, new_resource.distro) }
  end

  file "/var/lib/cobbler/kickstarts/#{new_resource.name}" do
    action :delete
    only_if { ::File.exist? "/var/lib/cobbler/kickstarts/#{new_resource.name}" }
  end

  exists?(new_resource.base_name, new_resource.distro)
end
