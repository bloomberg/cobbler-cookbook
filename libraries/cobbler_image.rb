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
    attribute(:source, kind_of: String)
    attribute(:target, kind_of: String, default: lazy { target_default })
    attribute(:checksum, kind_of: String)
    attribute(:os_version, kind_of: String)
    attribute(:os_arch, kind_of: String, default: 'x86_64')
    attribute(:os_kickstart, kind_of: String)
    attribute(:os_breed, kind_of: String)

    private
    def target_default
      ::File.join(Chef::Config[:file_cache_path], "#{name}#{::File.extname(source)}")
    end
  end

  class Provider::CobblerImage < Provider
    include Poise

    # Import the specified operating system image into the guest machine where
    # cobbler has been configured.
    def action_import
      converge_by("importing #{new_resource.name} into cobbler") do
        notifying_block do
          download_image
          execute_import
          remove_image
        end
      end
    end

    private

    # Fetch a remote target file from the source URI and with correct checksum.
    def download_image
      remote_file new_resource.target do
        source new_resource.source
        checksum new_resource.checksum
      end
    end

    # Run set of bash commands on the guest machine to import information of
    # the image into cobbler on the guest system.
    def execute_import
      bash 'cobbler-image-import' do
        code (<<-CODE)
mount -o loop -o ro #{new_resource.target} /mnt
cobbler import --name='#{new_resource.name}' \
 --path=/mnt \
 --breed=#{new_resource.os_breed} \
 --arch=#{new_resource.os_arch} \
 --os-version=#{new_resource.os_version} \
 --kickstart=#{new_resource.os_kickstart}
umount /mnt
cobbler sync
        CODE
        not_if { bash "cobbler profile list |grep #{new_resource.name}" }
      end

      # Delete the cached image (see #download_image) from the guest system.
      def remove_image
        file new_resource.target do
          action :delete
          only_if { ::File.exist? new_resource.target }
        end
      end
    end
  end
end
