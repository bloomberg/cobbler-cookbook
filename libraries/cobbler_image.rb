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
    attribute(:os_kickstart, kind_of: String)
    attribute(:os_kickstart_options, kind_of: String, default: lazy { 'interface=auto' })
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
          create_image
          cobbler_import
          cobbler_profile_add
          delete_image
        end
      end
    end

    private

    # Fetch a remote target file from the source URI and with correct checksum.
    def create_image
      remote_file new_resource.target do
        source new_resource.source
        checksum new_resource.checksum
        action :create_if_missing
      end
    end

    def cobbler_profile_add
      bash 'cobbler-profile-add' do
        code (<<-CODE)
cobbler profile add --name='#{new_resource.profile}' \
 --path='#{new_resource.name}' \
 --kickstart=#{new_resource.os_kickstart}
cobbler sync
CODE
        not_if "cobbler profile list |grep #{new_resource.profile}"
      end
    end

    # Run set of bash commands on the guest machine to import information of
    # the image into cobbler on the guest system.
    def cobbler_import
      bash 'cobbler-import' do
        code (<<-CODE)
mount -o loop -o ro #{new_resource.target} /mnt
cobbler import --name='#{new_resource.name}' \
 --path=/mnt \
 --breed=#{new_resource.os_breed} \
 --arch=#{new_resource.os_arch} \
 --os-version=#{new_resource.os_version} \
umount /mnt
cobbler sync
        CODE
        not_if "cobbler profile list |grep #{new_resource.name}"
      end

      # Delete the cached image (see #download_image) from the guest system.
      def delete_image
        file new_resource.target do
          action :delete
          only_if { ::File.exist? new_resource.target }
        end
      end
    end
  end
end
