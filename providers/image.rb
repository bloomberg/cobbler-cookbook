# rubocop:disable Style/GuardClause,Metrics/AbcSize

# Base Provider
include Cobbler::Parse

# Notifications are impacted here. If you do delayed notifications, they will be performed at the
# end of the resource run and not at the end of the chef run. You do want to use this as it also
# affects internal resource notifications.
use_inline_resources

# Create Action
action :create do
  if @current_resource.exists # Only create if it does not exist.
    Chef::Log.error "An image named #{@current_resource.name} already exists. Not importing."
    # Use this to raise exceptions that stop a chef run.
    # raise "Our file already exists."
  else
    # Converge our node
    converge_by("Importing a new image #{@new_resource.base_name}.") do
      resp = create
      # We set our updated flag based on the resource we utilized.
      @new_resource.updated_by_last_action(resp)
    end
  end
end

action :import do
  if @current_resource.exists # Only create if it does not exist.
    Chef::Log.error "A image named #{@current_resource.name} already exists. Not importing."
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
  if exists?(@new_resource.base_name)
    @current_resource = load_image(@new_resource.base_name)
    @current_resource.exists = true
  else
    # Copy new to current_resource
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
# Defines the allowable breed for the image type, used for input validation.
#------------------------------------------------------------
def breeds
  %w(suse redhat windows xen generic unix freebsd ubuntu nexenta debian vmware)
end

#------------------------------------------------------------
# Validates that the provided inputs do not include any reserved words or separate characters
#------------------------------------------------------------
def validate_input
  # Check if any restricted words are present
  bare_words = node['cobblerd']['image']['reserved_words']['bare_words']
  separators = node['cobblerd']['image']['reserved_words']['separators']
  arch = node['cobblerd']['image']['reserved_words']['arch']
  strings_caught = bare_words.select { |word| word if new_resource.name.include?(word) }
  all_strings = separators.collect do |sep|
    arch.collect do |a|
      sep + a if @new_resource.base_name.include?(sep + a)
    end
  end
  strings_caught += all_strings.flatten.select { |s| s }

  unless strings_caught.empty?
    msg = "Invalid cobbler image name #{@new_resource.base_name} -- "
    msg += "it would be changed by Cobbler\nContentious strings: #{strings_caught.join(', ')}"
    Chef::Application.fatal!(msg)
  end

  unless @new_resource.nil? || breeds.include?(@new_resource.os_breed)
    msg = "Invalid cobbler image breed #{@new_resource.os_breed} -- "
    msg += "must be one of #{breeds.join(',')}"
    Chef::Application.fatal!(msg)
  end
end

#------------------------------------------------------------
# Queries Cobbler to determine if a specific image exists.
#------------------------------------------------------------
def exists?(image_name = nil)
  Chef::Log.debug("Checking if image '#{image_name}' already exists")
  if image_name.nil?
    false
  else
    find_command = "cobbler image find --name=#{image_name} | grep '#{image_name}'"
    Chef::Log.debug("Searching for '#{image_name}' using #{find_command}")
    find = Mixlib::ShellOut.new(find_command)
    find.run_command
    Chef::Log.debug("Standard out from 'image find' is #{find.stdout.chomp}")
    # True if the value in stdout matches our image_name
    (find.stdout.chomp == image_name)
  end
end

#------------------------------------------------------------
# Creates a new system image.
#------------------------------------------------------------
def import
  validate_input
  is_new = !exists?

  bash "#{new_resource.name}-cobbler-import" do
    code <<-CODE
      cobbler import --name='#{new_resource.name}' \
       --path=#{::File.join(Chef::Config['file_cache_path'], 'mnt')} \
       --breed=#{new_resource.os_breed} \
       --arch=#{new_resource.architecture} \
       --os-version=#{new_resource.os_version}
    CODE
    notifies :umount, "mount[#{new_resource.name}-image]", :immediate
    notifies :delete, "directory[#{new_resource.name}-mount_point]", :delayed
    notifies :delete, "remote_file[#{new_resource.target}]", :immediate
    notifies :run, 'bash[cobbler-sync]', :delayed
    only_if { ::File.exist? new_resource.target }
  end

  cobbler_set_kernel(is_new) if new_resource.kernel
  cobbler_set_initrd(is_new) if new_resource.initrd
end

#------------------------------------------------------------
# Creates a new system image.
#------------------------------------------------------------
def create
  validate_input
  # is_new = !exists?
  setup_image_source

  command = "cobbler image add --name='#{new_resource.name}'"
  command = "#{command} --breed='#{new_resource.os_breed}'" unless new_resource.os_breed.nil?
  command = "#{command} --arch='#{new_resource.architecture}'" unless new_resource.architecture.nil?
  command = "#{command} --owners='#{new_resource.owners.join(',')}'" unless new_resource.owners.nil?
  command = "#{command} --comment='#{new_resource.comment}'" unless new_resource.comment.nil?
  command = "#{command} --ctime=#{new_resource.ctime}" unless new_resource.ctime.nil?
  command = "#{command} --mtime=#{new_resource.mtime}" unless new_resource.mtime.nil?

  bash "#{new_resource.name}-cobbler-create" do
    code command
    notifies :run, 'bash[cobbler-sync]', :delayed
  end

  # TODO: Are these needed and if so, why?
  # cobbler_set_kernel(is_new) if new_resource.kernel
  # cobbler_set_initrd(is_new) if new_resource.initrd
end

#------------------------------------------------------------
# Delete an existing image.
#------------------------------------------------------------
def delete
  if exists?(current_resource.base_name)
    bash "#{new_resource.name}-cobbler-delete" do
      code "cobbler image remove --name='#{current_resource.base_name}'"
    end
  end
end

#------------------------------------------------------------
# Download the image source locally and make it available under a specific directory / mount point.
#------------------------------------------------------------
def setup_image_source
  # File needs to be fully qualified otherwise the Chef::Provider::File class is used.
  if new_resource.source.nil?
    Chef::Log.error "Image source was not specified, no image source will be setup."
  else
    target_path = ::File.dirname(new_resource.target)
    directory target_path do
      owner 'root'
      group 'root'
      mode 0o0775
      recursive true
      not_if { target_path.nil? || target_path == ::File::SEPARATOR }
    end

    # create the remote_file to allow :delete to be called on it
    # but only :create if this is a new distribution
    remote_file new_resource.target do
      source new_resource.source
      mode 0o0444
      backup false
      checksum new_resource.checksum
      if is_new
        action :create
      else
        action :nothing
      end
      not_if { new_resource.target.nil? }
    end

    # Mount the image and then cobbler import the image
    directory "#{new_resource.name}-mount_point" do
      path ::File.join(Chef::Config['file_cache_path'], 'mnt')
      action :create
      only_if { ::File.exist? new_resource.target }
    end

    mount "#{new_resource.name}-image" do
      mount_point ::File.join(Chef::Config['file_cache_path'], 'mnt')
      device new_resource.target
      fstype 'iso9660'
      options %w(loop ro)
      action :mount
      only_if { ::File.exist? new_resource.target }
    end
  end
end

#------------------------------------------------------------
# Set the kernel to be used when booting an image.
#------------------------------------------------------------
def cobbler_set_kernel(force_run = false)
  # Import a specific kernel into the image
  # Arguments - force_run -- boolean as to if this should run without checking checksums
  Chef::Resource::RemoteFile.send('include', Cobbler::Parse)

  kernel_path = "#{node['cobblerd']['resource_storage']}/#{new_resource.name}-#{new_resource.architecture}"
  kernel_path = "#{kernel_path}/#{::File.basename(new_resource.kernel)}"

  directory ::File.dirname(kernel_path) do
    action :create
    recursive true
  end

  remote_file "#{new_resource.name}-kernel" do
    path kernel_path
    source new_resource.kernel
    mode 0o0444
    backup false
    checksum new_resource.kernel_checksum
    action :create
    only_if do
      if !force_run
        current_kernel = cobbler_distro(new_resource.name + "-" + new_resource.architecture, 'Kernel')
        if ::File.exist?(current_kernel)
          # run if we have a checksum and if it is different
          require 'digest'
          current_digest = Digest::SHA256.file(current_kernel).hexdigest
          (new_resource.kernel_checksum != current_digest) if new_resource.kernel_checksum
        else
          # run if file is missing
          true
        end
      else
        # run if force_run
        true
      end
    end
    notifies :run, "bash[#{new_resource.name}-cobbler-image-update-kernel]", :immediately
  end

  bash "#{new_resource.name}-cobbler-image-update-kernel" do
    cobbler_kernel_loc = "/var/lib/tftpboot/images/#{new_resource.name}-#{new_resource.architecture}"
    cobbler_kernel_loc = "#{cobbler_kernel_loc}/#{::File.basename(new_resource.kernel)}"
    code <<-CODE
      cobbler image edit --name='#{new_resource.name}-#{new_resource.architecture}' \
       --kernel='#{kernel_path}' \
       --breed=#{new_resource.os_breed} \
       --arch=#{new_resource.architecture} \
       --os-version=#{new_resource.os_version}
    CODE
    action :run
    not_if do
      if ::File.exist?(cobbler_kernel_loc) && new_resource.kernel_checksum
        new_resource.kernel_checksum == Digest::SHA256.file(cobbler_kernel_loc).hexdigest
      else
        true
      end
    end
    notifies :run, 'bash[cobbler-sync]', :delayed
  end
end

#------------------------------------------------------------
# Set the initrd image used for booting an image.
#------------------------------------------------------------
def cobbler_set_initrd(force_run = false)
  # Import a specific initrd into the distro
  # Arguments - force_run -- boolean as to if this should run without checking checksums
  Chef::Resource::RemoteFile.send('include', Cobbler::Parse)

  initrd_path = "#{node['cobblerd']['resource_storage']}/#{new_resource.name}-#{new_resource.architecture}"
  initrd_path = "#{initrd_path}/#{::File.basename(new_resource.initrd)}"

  directory ::File.dirname(initrd_path) do
    action :create
    recursive true
  end

  remote_file "#{new_resource.name}-initrd" do
    path initrd_path
    source new_resource.initrd
    mode 0o0444
    backup false
    checksum new_resource.initrd_checksum
    action :create
    only_if do
      if !force_run
        current_initrd = cobbler_distro(new_resource.name + "-" + new_resource.architecture, "Initrd")
        if ::File.exist?(current_initrd)
          # run if we have a checksum and if it is different
          require 'digest'
          unless new_resource.initrd_checksum.nil?
            new_resource.initrd_checksum != Digest::SHA256.file(current_initrd).hexdigest
          end
        else
          true # run if file is missing
        end
      else
        true # run if force_run
      end
    end
    notifies :run, "bash[#{new_resource.name}-cobbler-distro-update-initrd]", :immediately
  end

  bash "#{new_resource.name}-cobbler-distro-update-initrd" do
    # Multiple lines to avoid Rubocop Line Length warnings
    cobbler_initrd_loc = "/var/lib/tftpboot/images/#{new_resource.name}-#{new_resource.architecture}"
    cobbler_initrd_loc = "#{cobbler_initrd_loc}/#{::File.basename(new_resource.initrd)}"
    code <<-CODE
      cobbler distro edit --name='#{new_resource.name}-#{new_resource.architecture}' \
       --initrd='#{initrd_path}' \
       --breed=#{new_resource.os_breed} \
       --arch=#{new_resource.architecture} \
       --os-version=#{new_resource.os_version}
    CODE
    action :run
    not_if do
      if ::File.exist?(cobbler_initrd_loc) && new_resource.initrd_checksum
        new_resource.initrd_checksum == Digest::SHA256.file(cobbler_initrd_loc).hexdigest
      else
        true
      end
    end
    notifies :run, 'bash[cobbler-sync]', :delayed
  end
end
