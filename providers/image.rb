# rubocop:disable Style/GuardClause

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

# Override Load Current Resource
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

def breed
  # return breed (e.g. "redhat", "debian", "ubuntu" or "suse")
  @breed ||= cobbler_distro(distro, "Breed")
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
# Queries Cobbler to determine if a specific image exists.
#------------------------------------------------------------
def exists?(image_name = nil)
  if repo_name.nil?
    false
  else
    find_command = "cobbler image find --name=#{image_name} | grep '#{image_name}'"
    find = Mixlib::ShellOut.new(find_command)
    find.run_command
    find.stdout == repo_name
  end
end

#------------------------------------------------------------
# Creates a new system image.
#------------------------------------------------------------
def import
  validate_input

  is_new_repo = exists?

  # create the remote_file to allow :delete to be called on it
  # but only :create if this is a new distribution
  remote_file new_resource.target do
    source new_resource.source
    mode 0o0444
    backup false
    checksum new_resource.checksum
    if is_new_repo
      action :create
    else
      action :nothing
    end
  end

  # TODO: Optionally download the image source if the source starts with http/https/ftp/s3

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

  bash "#{new_resource.name}-cobbler-import" do
    code <<-CODE
      cobbler import --name='#{new_resource.name}' \
       --path=#{::File.join(Chef::Config['file_cache_path'], 'mnt')} \
       --breed=#{new_resource.os_breed} \
       --arch=#{new_resource.os_arch} \
       --os-version=#{new_resource.os_version}
    CODE
    notifies :umount, "mount[#{new_resource.name}-image]", :immediate
    notifies :delete, "directory[#{new_resource.name}-mount_point]", :delayed
    notifies :delete, "remote_file[#{new_resource.target}]", :immediate
    notifies :run, 'bash[cobbler-sync]', :delayed
    only_if { ::File.exist? new_resource.target }
  end

  cobbler_set_kernel(is_new_repo) if new_resource.kernel
  cobbler_set_initrd(is_new_repo) if new_resource.initrd
end

def delete
  false
end

def cobbler_set_kernel(force_run = false)
  # Import a specific kernel into the distro
  # Arguments - force_run -- boolean as to if this should run without checking checksums
  Chef::Resource::RemoteFile.send('include', Cobbler::Parse)

  kernel_path = "#{node['cobblerd']['resource_storage']}/#{new_resource.name}-#{new_resource.os_arch}"
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
        current_kernel = cobbler_distro(new_resource.name + "-" + new_resource.os_arch, 'Kernel')
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
    notifies :run, "bash[#{new_resource.name}-cobbler-distro-update-kernel]", :immediately
  end

  bash "#{new_resource.name}-cobbler-distro-update-kernel" do
    cobbler_kernel_loc = "/var/lib/tftpboot/images/#{new_resource.name}-#{new_resource.os_arch}"
    cobbler_kernel_loc = "#{cobbler_kernel_loc}/#{::File.basename(new_resource.kernel)}"
    code <<-CODE
      cobbler distro edit --name='#{new_resource.name}-#{new_resource.os_arch}' \
       --kernel='#{kernel_path}' \
       --breed=#{new_resource.os_breed} \
       --arch=#{new_resource.os_arch} \
       --os-version=#{new_resource.os_version}
    CODE
    action :run
    not_if do
      if ::File.exist? cobbler_kernel_loc && new_resource.kernel_checksum
        new_resource.kernel_checksum == Digest::SHA256.file(cobbler_kernel_loc).hexdigest
      else
        true
      end
    end
    notifies :run, 'bash[cobbler-sync]', :delayed
  end
end

def cobbler_set_initrd(force_run = false)
  # Import a specific initrd into the distro
  # Arguments - force_run -- boolean as to if this should run without checking checksums
  Chef::Resource::RemoteFile.send('include', Cobbler::Parse)

  initrd_path = "#{node['cobblerd']['resource_storage']}/#{new_resource.name}-#{new_resource.os_arch}"
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
        current_initrd = cobbler_distro(new_resource.name + "-" + new_resource.os_arch, "Initrd")
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
    cobbler_initrd_loc = "/var/lib/tftpboot/images/#{new_resource.name}-#{new_resource.os_arch}"
    cobbler_initrd_loc = "#{cobbler_initrd_loc}/#{::File.basename(new_resource.initrd)}"
    code <<-CODE
      cobbler distro edit --name='#{new_resource.name}-#{new_resource.os_arch}' \
       --initrd='#{initrd_path}' \
       --breed=#{new_resource.os_breed} \
       --arch=#{new_resource.os_arch} \
       --os-version=#{new_resource.os_version}
    CODE
    action :run
    not_if do
      if ::File.exist? cobbler_initrd_loc && new_resource.initrd_checksum
        new_resource.initrd_checksum == Digest::SHA256.file(cobbler_initrd_loc).hexdigest
      else
        true
      end
    end
    notifies :run, 'bash[cobbler-sync]', :delayed
  end
end
