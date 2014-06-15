#
# Cookbook Name:: cobblerd
# Provider:: image
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#

def image_type_from_filename(filename)
  case Filename.extname(filename)
  when 'iso'
    return 'iso'
  else
    return 'direct'
  end
end

action :add do
  basename = File.basename(new_resource.source)
  filename = File.join(Chef::Config[:file_cache_path], basename)
  type = image_type_from_filename(basename)

  remote_file filename  do
    source new_resource.source
    checksum new_resource.checksum
  end

  bash "cobbler image add --name=#{new_resource.name} --file=#{filename} --image-type=#{type}"
end

action :remove do
  basename = File.basename(new_resource.source)
  filename = File.join(Chef::Config[:file_cache_path], basename)

  file filename do
    action :delete
    only_if { File.exist? filename }
  end

  bash "cobbler image remove --name=#{new_resource.name}"
end
