# rubocop:disable Style/GuardClause,Metrics/AbcSize

# Base Provider
include Cobbler::Parse

# Notifications are impacted here. If you do delayed notifications, they will be performed at the
# end of the resource run and not at the end of the chef run. You do want to use this as it also
# affects internal resource notifications.
use_inline_resources

# Create Action
action :import do
  if @current_resource.exists # Only create if it does not exist.
    Chef::Log.error "A repository named #{@current_resource.name} already exists. Not importing."
    # Use this to raise exceptions that stop a chef run.
    # raise "Our file already exists."
  else
    # Converge our node
    converge_by("Importing a new image #{@new_resource.base_name}.") do
      resp = import
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
    converge_by("Deleting image #{@new_resource.base_name}") do
      resp = delete
      @new_resource.updated_by_last_action(resp)
    end
  else
    Chef::Log.error "Our file does not exist. Not deleting."
  end
end

def whyrun_supported?
  true
end

#------------------------------------------------------------
# Override Load Current Resource
#------------------------------------------------------------
def load_current_resource
  puts @new_resource
  @current_resource = @new_resource.clone
  @current_resource.source = @new_resource.source
  @current_resource.target = @new_resource.target
  @current_resource.checksum = @new_resource.checksum
  @current_resource.exists = ::File.exist?(@new_resource.target)
end

#------------------------------------------------------------
# Creates a new system ISO.
#------------------------------------------------------------
def import
  # Mount the image and then cobbler import the image
  directory "#{new_resource.base_name}-iso-target" do
    path ::File.dirname(new_resource.target)
    owner 'root'
    group 'root'
    mode 0o0775
    recursive true
    action :create
  end

  # create the remote_file to allow :delete to be called on it
  # but only :create if this is a new distribution
  remote_file new_resource.target do
    source new_resource.source
    mode 0o0444
    backup false
    checksum new_resource.checksum
    action :create
    not_if { ::File.exist? new_resource.target }
  end

  # Mount the image and then cobbler import the image
  directory "#{new_resource.base_name}-iso-mount_point" do
    path "/var/www/cobbler/images/#{new_resource.base_name}"
    action :create
    only_if { ::File.exist? new_resource.target }
  end

  mount "#{new_resource.base_name}-iso" do
    mount_point "/var/www/cobbler/images/#{new_resource.base_name}"
    device new_resource.target
    fstype 'iso9660'
    options %w(loop ro)
    action [:mount, :enable]
    only_if { ::File.exist? new_resource.target }
  end
end

#------------------------------------------------------------
# Delete an existing image.
#------------------------------------------------------------
def delete
  if current_resource.exists
    mount "#{new_resource.base_name}-iso" do
      mount_point "/var/www/cobbler/images/#{current_resource.base_name}"
      device current_resource.target
      fstype 'iso9660'
      options %w(loop ro)
      action [:umount, :disable]
      only_if { ::File.exist? current_resource.target }
      only_if "mount | grep '/var/www/cobbler/images/#{current_resource.base_name}'"
    end

    # Mount the image and then cobbler import the image
    directory "#{current_resource.base_name}-iso-mount_point" do
      path "/var/www/cobbler/images/#{current_resource.base_name}"
      action :delete
    end

    # create the remote_file to allow :delete to be called on it
    # but only :create if this is a new distribution
    remote_file current_resource.target do
      source current_resource.source
      mode 0o0444
      backup false
      checksum current_resource.checksum
      action :delete
      not_if { ::File.exist? current_resource.target }
    end
  end
end
