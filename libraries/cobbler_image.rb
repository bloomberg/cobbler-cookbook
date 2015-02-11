#
# Cookbook Name:: cobblerd
# Library:: image
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#

class Chef
  class Resource::CobblerImage < Resource
    include Poise

    actions(:import)

    # WARNING: some options are not idempotent:
    # source - will not update if changed after creation
    # target - will not update if changed after creation
    # os_version - will not update if changed after creation
    # os_arch - will not update if changed after creation
    # os_breed - will not update if changed after creation
    # initrd - will not update if changed after creation w/o checksum
    # kernel - will not update if changed after creation w/o checksum
    attribute(:name, kind_of: String)
    attribute(:source, kind_of: String, required: true)
    attribute(:initrd, kind_of: String, default: nil)
    attribute(:initrd_checksum, kind_of: String, default: nil)
    attribute(:kernel, kind_of: String, default: nil)
    attribute(:kernel_checksum, kind_of: String, default: nil)
    attribute(:target, kind_of: String, default: lazy { target_default })
    attribute(:checksum, kind_of: String)
    attribute(:os_version, kind_of: String)
    attribute(:os_arch, kind_of: String, default: 'x86_64')
    attribute(:os_breed, kind_of: String, required: true)

    private
    def target_default
      ::File.join(Chef::Config[:file_cache_path], "#{name}#{::File.extname(source)}")
    end
  end

  class Provider::CobblerImage < Provider
    include Poise

    # Verify the resource name before importing image
    def action_import
      converge_by("importing #{new_resource.name} into cobbler") do
        notifying_block do

          # Check if any restricted words are present
          bare_words = node[:cobbler][:distro][:reserved_words][:bare_words]
          separators = node[:cobbler][:distro][:reserved_words][:separators]
          arch = node[:cobbler][:distro][:reserved_words][:arch]
          strings_caught = bare_words.select{ |word| word if new_resource.name.include?(word) }
          strings_caught = strings_caught + separators.collect{ |sep| arch.collect{ |arch| sep+arch if new_resource.name.include?(sep+arch) } }.flatten.select{|s| s}
          if strings_caught.length > 0 then
            Chef::Application.fatal!("Invalid cobbler image name #{new_resource.name} -- it would be changed by Cobbler\nContentious strings: #{strings_caught.join(', ')}")
          end

          # flag if this is a new distro
          distro_chk = Mixlib::ShellOut.new("cobbler distro report --name='#{new_resource.name}-#{new_resource.os_arch}'")
          distro_chk.run_command
          new_distro = distro_chk.error? ? true : false

          # create the remote_file to allow :delete to be called on it
          # but only :create if this is a new distribution
          iso_action = generate_remote_file_action
          if new_distro
            iso_action.send(:action,:create)
          end

          cobbler_import

          cobbler_set_kernel(force_run = new_distro) if new_resource.kernel
          cobbler_set_initrd(force_run = new_distro) if new_resource.initrd
        end
      end
    end

    private

    # Return the resource to fetch a remote target file for the image
    def generate_remote_file_action
      return remote_file new_resource.target do
        source new_resource.source
        mode 0444
        backup false
        checksum new_resource.checksum
        action :nothing
      end
    end

    # Mount the image and then cobbler import the image
    def cobbler_import
      directory 'mount_point' do
        path "#{::File.join(Chef::Config[:file_cache_path], 'mnt')}"
        action :create
        only_if { ::File.exist? new_resource.target }
      end

      mount 'image' do
        mount_point "#{::File.join(Chef::Config[:file_cache_path], 'mnt')}"
        device new_resource.target
        fstype 'iso9660'
        options ['loop','ro'] 
        action :mount
        only_if { ::File.exist? new_resource.target }
      end

      bash 'cobbler-import' do
        code (<<-CODE)
          cobbler import --name='#{new_resource.name}' \
           --path=#{::File.join(Chef::Config[:file_cache_path], 'mnt')} \
           --breed=#{new_resource.os_breed} \
           --arch=#{new_resource.os_arch} \
           --os-version=#{new_resource.os_version}
        CODE
        notifies :umount, 'mount[image]', :immediate
        notifies :delete, 'directory[mount_point]', :delayed
        notifies :delete, "remote_file[#{new_resource.target}]", :immediate
        notifies :run, 'bash[cobbler-sync]', :delayed
        only_if { ::File.exist? new_resource.target }
      end

      bash 'verify cobbler-import' do
        code "cobbler distro report --name='#{new_resource.name}-#{new_resource.os_arch}'"
      end
    end

    def cobbler_set_kernel(force_run = false)
      # Import a specific kernel into the distro
      # Arguments - force_run -- boolean as to if this should run without checking checksums
      Chef::Resource::RemoteFile.send(:include, Cobbler::Parse)

      kernel_path = "#{node[:cobblerd][:resource_storage]}/#{new_resource.name}-#{new_resource.os_arch}/#{::File.basename(new_resource.kernel)}"

      directory ::File.dirname(kernel_path) do
        action :create
        recursive true
      end

      remote_file "kernel" do
        path kernel_path
        source new_resource.kernel
        mode 0444
        backup false
        checksum new_resource.kernel_checksum
        action :create
        only_if {
          if !force_run
            current_kernel = cobbler_distro(new_resource.name+"-"+new_resource.os_arch, "Kernel")
            if ::File.exist?(current_kernel)
              # run if we have a checksum and if it is different
              require 'digest'
              (new_resource.kernel_checksum != Digest::SHA256.file(current_kernel).hexdigest) if new_resource.kernel_checksum
            else
              true # run if file is missing
            end
          else
            true # run if force_run
          end
        }
        notifies :run, "bash[cobbler-distro-update-kernel]", :immediately
      end

      bash 'cobbler-distro-update-kernel' do
        code (<<-CODE)
          cobbler distro edit --name='#{new_resource.name}-#{new_resource.os_arch}' \
           --kernel='#{kernel_path}' \
           --breed=#{new_resource.os_breed} \
           --arch=#{new_resource.os_arch} \
           --os-version=#{new_resource.os_version}
        CODE
        action :nothing
        notifies :run, 'bash[cobbler-sync]', :delayed
      end
    end

    def cobbler_set_initrd(force_run = false)
      # Import a specific initrd into the distro
      # Arguments - force_run -- boolean as to if this should run without checking checksums
      Chef::Resource::RemoteFile.send(:include, Cobbler::Parse)

      initrd_path = "#{node[:cobbler][:resource_storage]}/#{new_resource.name}-#{new_resource.os_arch}/#{::File.basename(new_resource.initrd)}"

      directory ::File.dirname(initrd_path) do
        action :create
        recursive true
      end

      remote_file "initrd" do
        path initrd_path
        source new_resource.initrd
        mode 0444
        backup false
        checksum new_resource.initrd_checksum
        action :create
        only_if {
          if !force_run
            current_initrd = cobbler_distro(new_resource.name+"-"+new_resource.os_arch, "Initrd")
            if ::File.exist?(current_initrd)
              # run if we have a checksum and if it is different
              require 'digest'
              (new_resource.initrd_checksum != Digest::SHA256.file(current_initrd).hexdigest) if new_resource.initrd_checksum
            else
              true # run if file is missing
            end
          else
            true # run if force_run
          end
        }
        notifies :run, "bash[cobbler-distro-update-initrd]", :immediately
      end

      bash 'cobbler-distro-update-initrd' do
        code (<<-CODE)
          cobbler distro edit --name='#{new_resource.name}-#{new_resource.os_arch}' \
           --initrd='#{initrd_path}' \
           --breed=#{new_resource.os_breed} \
           --arch=#{new_resource.os_arch} \
           --os-version=#{new_resource.os_version}
        CODE
        action :nothing
        notifies :run, 'bash[cobbler-sync]', :delayed
      end
    end
  end
end
