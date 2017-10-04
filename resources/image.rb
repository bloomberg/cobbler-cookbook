# rubocop:disable Style/GuardClause,Metrics/AbcSize
provides :cobbler_image
resource_name :cobbler_image

# Required for 'import', but not 'delete', so not marking as required.
# Actions that we support.  Must be stated in our provider action :create do.
actions :create, :import, :delete

# Our default action, can be anything.
default_action :create if defined?(default_action)

property :name, name_attribute: true, kind_of: String, required: true

property :architecture, kind_of: String, required: true, desired_state: false, default: 'x86_64'
property :auto_boot, kind_of: [TrueClass, FalseClass], required: false, desired_state: false, default: nil
property :bridge, kind_of: String, required: false, desired_state: false, default: nil
property :checksum, kind_of: String, required: false, desired_state: false, default: nil
property :comment, kind_of: String, required: false, desired_state: false, default: nil
property :cpus, kind_of: String, required: false, desired_state: false, default: "1"
property :ctime, kind_of: String, required: false, desired_state: false, default: nil
property :disk_driver_type, kind_of: String, required: false, desired_state: false, default: nil
property :disk_path, kind_of: String, required: false, desired_state: false, default: nil
property :disk_size, kind_of: Integer, required: false, desired_state: false, default: 16
# Must be one of iso,direct,memdisk,virt-image
property :image_type, kind_of: String, required: false, desired_state: false, default: 'iso'
property :kickstart, kind_of: String, required: false, desired_state: false, default: nil
property :mtime, kind_of: String, required: false, desired_state: false, default: nil
# Number of NICs, corresponds to the --network-count input
property :network_count, kind_of: Integer, required: false, desired_state: false, default: 1
property :os_breed, kind_of: String, required: false, desired_state: false, default: nil
property :os_version, kind_of: String, required: false, desired_state: false, default: nil
property :owners, kind_of: Array, required: true, desired_state: false, default: ['admin']
property :ram, kind_of: Integer, required: false, desired_state: false, default: 1024
# This is the source for the remote image file that will be downloaded if a value is specified.
property :source, kind_of: String, required: false, desired_state: false, default: nil
# This corresopnds to the --file input and can be a local file or an NFS mount
property :target, kind_of: String, required: false, desired_state: false, default: nil
property :virtualization_type, kind_of: String, required: false, desired_state: false, default: nil

# This is a standard ruby accessor, use this to set flags for current state.
attr_accessor :exists
attr_accessor :children

# Create Action
action :create do
  validate_input

  if !exists?
    command = "cobbler image add --name='#{new_resource.name}'"
    command = "#{command} --breed='#{new_resource.os_breed}'" unless new_resource.os_breed.nil?
    command = "#{command} --arch='#{new_resource.architecture}'" unless new_resource.architecture.nil?
    command = "#{command} --owners='#{new_resource.owners.join(',')}'" unless new_resource.owners.nil?
    command = "#{command} --comment='#{new_resource.comment}'" unless new_resource.comment.nil?
    command = "#{command} --ctime=#{new_resource.ctime}" unless new_resource.ctime.nil?
    command = "#{command} --mtime=#{new_resource.mtime}" unless new_resource.mtime.nil?

    bash "#{new_resource.name}-cobbler-image-create" do
      code command
      notifies :run, 'bash[cobbler-sync]', :delayed
    end
  end

  # TODO: Are these needed and if so, why?
  # cobbler_set_kernel(is_new) if new_resource.kernel
  # cobbler_set_initrd(is_new) if new_resource.initrd
end

action :import do
  validate_input

  # Mount the image and then cobbler import the image
  mount_point = ::File.join('/data/mount', ::File.basename(new_resource.target, '.iso'))
  mount_regex = "#{new_resource.target} on #{mount_point}"
  directory "#{new_resource.name}-mount_point" do
    path mount_point
    action :create
    recursive true
    owner 'root'
    group 'root'
    mode 0o0555
    only_if { ::File.exist? new_resource.target }
    not_if "mount | grep '#{mount_regex}'"
  end


  mount "#{new_resource.name}-image" do
    mount_point mount_point
    device new_resource.target
    fstype 'iso9660'
    options %w[loop ro]
    action :mount
    only_if { ::File.exist? new_resource.target }
  end

  # TODO: Add option to clobber (remove) existing resources (image, distro, profile) and force a re-import.
  # Only import the image if it doesn't exist and if any dependencies
  if !exists? && !dependencies?
    command = "cobbler import --name='#{new_resource.name}'"
    command = "#{command} --path='#{mount_point}'"
    command = "#{command} --breed=#{new_resource.os_breed}" unless new_resource.os_breed.nil?
    command = "#{command} --arch=#{new_resource.architecture}" unless new_resource.architecture.nil?
    command = "#{command} --os-version=#{new_resource.os_version}" unless new_resource.os_version.nil?

    # TODO: This has a problem if the name is reused but the source changes; doing so can result in errors like
    # "received on stderr: could not make way for new symlink: repodata"
    # so a mechanism is needed if the source for the import changes, then an error needs to be thrown.
    bash "#{new_resource.name}-cobbler-image-import" do
      code command
      notifies :umount, "mount[#{new_resource.name}-image]", :immediate
      notifies :run, 'bash[cobbler-sync]', :delayed
      only_if { ::File.exist? new_resource.target }
    end

    # TODO: Re-establish this code (the functions were deleted with the expectation they are not needed)
    # cobbler_set_kernel(is_new) if new_resource.kernel
    # cobbler_set_initrd(is_new) if new_resource.initrd
  end
end

# Delete Action
action :delete do
  if exists?
    image_command = "cobbler image remove --name='#{name}'"
    bash "#{name}-cobbler-image-delete" do
      code image_command
      umask 0o0002
    end
  end
end

load_current_value do
  if exists?
    data = load_cobbler_image

    # TODO: Use the 'send' feature / function to programatically (and dynamically) do this.
    architecture data['arch']
    auto_boot data['virt_auto_boot'].nil? || data['virt_auto_boot'] == '0' ? false : true
    bridge data['virt_bridge']
    # NOTE: Checksum is not a Cobbler property; it is for use with the remote_file from the import action.
    comment data['comment']
    cpus data['virt_cpus'].to_s
    ctime data['ctime'].to_s
    disk_driver_type data['virt_disk_driver']
    disk_path data['virt_path']
    disk_size data['virt_file_size']
    image_type data['image_type']
    kickstart data['kickstart']
    mtime data['mtime'].to_s
    network_count data['network_count']
    os_breed data['breed']
    os_version data['os_version']
    owners data['owners']
    ram data['virt_ram']
    source data['source']
    target data['target']
    virtualization_type data['virt_type']
  end
end

#------------------------------------------------------------
# Queries Cobbler to determine if a specific image exists.
#------------------------------------------------------------
def exists?
  Chef::Log.debug("Checking if image '#{name}' already exists")
  if name.nil?
    false
  else
    find_command = "cobbler image find --name='#{name}' | grep '#{name}'"
    Chef::Log.info("Searching for image '#{name}' using #{find_command}")
    image_find = Mixlib::ShellOut.new(find_command)
    image_find.run_command
    Chef::Log.debug("Standard out from 'image find' is #{image_find.stdout.chomp}")

    # True if the value in stdout matches our name
    (image_find.stdout.chomp == "#{name}")
  end
end

def dependencies?
  fullname = "#{name}-#{architecture}"
  Chef::Log.debug("Checking if image '#{fullname}' already exists")
  if name.nil?
    false
  else
    find_command = "cobbler distro find --name='#{fullname}' | grep '#{fullname}'"
    Chef::Log.info("Searching for distro '#{fullname}-#{architecture}' using #{find_command}")
    distro_find = Mixlib::ShellOut.new(find_command)
    distro_find.run_command
    Chef::Log.debug("Standard out from 'distro list' is #{distro_find.stdout.chomp}")

    find_command = "cobbler profile find --name='#{fullname}' | grep '#{fullname}'"
    Chef::Log.info("Searching for profile '#{fullname}' using #{find_command}")
    profile_find = Mixlib::ShellOut.new(find_command)
    profile_find.run_command
    Chef::Log.debug("Standard out from 'profile list' is #{profile_find.stdout.chomp}")

    # True if the value in stdout matches our name
    (distro_find.stdout.chomp == "#{fullname}") || (profile_find.stdout.chomp == "#{fullname}")
  end
end

def load_cobbler_image # rubocop:disable Metrics/AbcSize
  retval = {}
  config_file = ::File.join('/var/lib/cobbler/config/images.d/', "#{name}.json")
  if ::File.exist?(config_file)
    retval = JSON.parse(::File.read(config_file))
  else
    Chef::Log.error("Configuration file #{config_file} needed to load the existing image does not exist")
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
  # Defines the allowable breed for the image type, used for input validation.
  #------------------------------------------------------------
  def breeds
    %w[suse redhat windows xen generic unix freebsd ubuntu nexenta debian vmware]
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
        sep + a if new_resource.name.include?(sep + a)
      end
    end
    strings_caught += all_strings.flatten.select { |s| s }

    unless strings_caught.empty?
      msg = "Invalid cobbler image name #{new_resource.name} -- "
      msg += "it would be changed by Cobbler\nContentious strings: #{strings_caught.join(', ')}"
      Chef::Application.fatal!(msg)
    end

    unless new_resource.nil? || breeds.include?(new_resource.os_breed)
      msg = "Invalid cobbler image breed #{new_resource.os_breed} -- "
      msg += "must be one of #{breeds.join(',')}"
      Chef::Application.fatal!(msg)
    end
  end

  require 'etc'
  require 'digest'
end
