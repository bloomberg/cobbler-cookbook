# rubocop:disable Style/GuardClause,Metrics/AbcSize
provides :cobbler_iso
resource_name :cobbler_iso

# Our default action, can be anything.
default_action :download if defined?(default_action)

# Required for 'import', but not 'delete', so not marking as required.
property :name, name_attribute: true, kind_of: String, required: true
property :source, kind_of: String, required: false, desired_state: false
property :target, kind_of: String, required: false, desired_state: false
property :mode, kind_of: Integer, required: false, desired_state: false, default: 0o0664
property :owner, kind_of: String, required: false, desired_state: false, default: 'root'
property :group, kind_of: String, required: false, desired_state: false, default: 'root'
property :checksum, kind_of: String, required: false, desired_state: false, default: nil

# Create Action
action :download do
  # Mount the image and then cobbler import the image
  dirname = ::File.dirname(target)
  directory dirname do
    owner 'root'
    group 'root'
    mode 0o0775
    recursive true
    action :create
  end

  Chef::Log.debug("Retrieving remote file to #{new_resource.target} with checksum #{new_resource.checksum}")
  remote_file new_resource.target do
    source new_resource.source
    mode new_resource.mode
    backup false
    checksum new_resource.checksum if new_resource.checksum
    action :create
  end

  converge_if_changed :mode do
    ::File.chmod(new_resource.mode, new_resource.target)
  end

  converge_if_changed :owner do
    uid = if new_resource.owner == 'root'
            0
          else
            Etc.getpwname(new_resource.owner).uid
          end
    ::File.chown(uid, nil, new_resource.target)
  end

  converge_if_changed :group do
    gid = if new_resource.group == 'root'
            0
          else
            Etc.getgrname(new_resource.group).gid
          end
    ::File.chown(nil, gid, new_resource.target)
  end
end

load_current_value do
  Chef::Log.debug("Checking for existing #{target}")
  if ::File.exist?(target)
    Chef::Log.debug("Found existing #{target}, comparing supplied checksum of #{checksum}")

    # Get the file information and set the attribute values to those from the file itself.
    stats = ::File.stat(target)
    mode stats.mode
    owner Etc.getpwuid(stats.uid).name
    group Etc.getgrgid(stats.gid).name

    checksum Digest::SHA256.file(target).hexdigest
    Chef::Log.debug("Loaded existing file from #{target} with checksum mode #{mode} and owner #{owner}:#{group}")
  end
end

action_class do
  require 'etc'
  require 'digest'
end
