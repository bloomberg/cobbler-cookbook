#
# Cookbook Name:: cobblerd
# Library:: image
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#
class Chef
  class Resource::CobblerImage < Resource
    include Poise

    actions(:import)

    attribute(:name, kind_of: String)
    attribute(:profile, kind_of: String, default: lazy { name })
    attribute(:source, kind_of: String)
    attribute(:target, kind_of: String, default: lazy { target_default })
    attribute(:checksum, kind_of: String)
    attribute(:os_version, kind_of: String)
    attribute(:os_arch, kind_of: String, default: 'x86_64')
    attribute(:os_breed, kind_of: String)

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
        # Check if any restricted words are present
        notifying_block do
          bare_words = node[:cobbler][:distro][:reserved_words][:bare_words]
          separators = node[:cobbler][:distro][:reserved_words][:separators]
          arch = node[:cobbler][:distro][:reserved_words][:arch]
          strings_caught = bare_words.select{ |word| word if new_resource.name.include?(word) }
          strings_caught = strings_caught + separators.collect{ |sep| arch.collect{ |arch| sep+arch if new_resource.name.include?(sep+arch) } }.flatten.select{|s| s}
          if strings_caught.length > 0 then
            Chef::Application.fatal!("Invalid cobbler image name #{new_resource.name} -- it would be changed by Cobbler\nContentious strings: #{strings_caught.join(', ')}")
          end
          cobbler_import
        end
      end
    end

    private

    # Fetch a remote target file for the image, mount it and then cobbler import the image
    def cobbler_import
      remote_file new_resource.target do
        source new_resource.source
        checksum new_resource.checksum
        action :create_if_missing
        not_if "cobbler distro report --name='#{new_resource.name}-#{new_resource.os_arch}'"
      end

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
  end
end
