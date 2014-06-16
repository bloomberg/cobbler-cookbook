#
# Cookbook Name:: cobblerd
# Provider:: image
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#

action :import do
  basename = ::File.basename(new_resource.source)
  filename = ::File.join(Chef::Config[:file_cache_path], basename)

  remote_file filename  do
    source new_resource.source
    checksum new_resource.checksum
  end

  bash 'cobbler-import-image' do
    user 'root'
    code (<<-CODE)
mount -o loop -o ro #{filename} /mnt
cobbler import --name=#{new_resource.name} \
  --path=/mnt \
  --breed=#{new_resource.breed} \
  --arch=#{new_resource.arch} \
  --os-version=#{new_resource.os_version}
  --kickstart=#{new_resource.kickstart}
unmount /mnt
cobbler sync
CODE
  end
end
