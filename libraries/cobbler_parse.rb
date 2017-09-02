module Cobbler
  # Parse Cobbler output
  module Parse
    include Chef::Mixin::ShellOut

    unless defined? DISTRO_FIELDS
      DISTRO_FIELDS = {
        'Name' => { attribute: 'base_name', type: 'string' },
        'Architecture' => { attribute: 'architecture', type: 'string' },
        # Parse as JSON
        'TFTP Boot Files' => { attribute: 'boot_files', type: 'array' },
        'Breed' => { attribute: 'os_breed', type: 'string' },
        'Comment' => { attribute: 'comment', type: 'string' },
        # Parse as JSON
        'Fetchable Files' => { attribute: 'fetchable_files', type: 'hash' },
        'Initrd' => { attribute: 'initrd', type: 'string' },
        'Kernel' => { attribute: 'kernel', type: 'string' },
        # Parse as JSON
        'Kernel Options' => { attribute: 'kernel_options', type: 'hash' },
        # Parse as JSON
        'Kernel Options (Post Install)' => { attribute: 'kernel_options_postinstall', type: 'hash' },
        # Parse as JSON
        'Kickstart Metadata' => { attribute: 'kickstart_meta', type: 'hash' },
        # Strip braces and parse as CSV
        'Management Classes' => { attribute: 'mgmt_classes', type: 'array' },
        'OS Version' => { attribute: 'os_version', type: 'string' },
        # Strip braces and parse as CSV
        'Owners' => { attribute: 'owners', type: 'array' },
        'Red Hat Management Key' => { attribute: 'redhat_management_key', type: 'string' },
        'Red Hat Management Server' => { attribute: 'redhat_management_server', type: 'string' },
        # Parse as JSON
        'Template Files' => { attribute: 'template_files', type: 'hash' }
      }.freeze
    end

    unless defined? IMAGE_FIELDS
      IMAGE_FIELDS = {
        'Name' => { attribute: 'base_name', type: 'string' },
        'Architecture' => { attribute: 'architecture', type: 'string' },
        'Breed' => { attribute: 'os_breed', type: 'string' },
        'Comment' => { attribute: 'comment', type: 'string' },
        'File' => { attribute: 'source', type: 'string' },
        'Image Type' => { attribute: 'image_type', type: 'string' },
        'Kickstart' => { attribute: 'kickstart', type: 'string' },
        'Virt NICs' => { attribute: 'network_count', type: 'string' },
        'OS Version' => { attribute: 'os_version', type: 'string' },
        # Strip braces and parse as CSV
        'Owners' => { attribute: 'owners', type: 'array' },
        'Parent' => { attribute: 'parent', type: 'string' },
        'Virt Auto Boot' => { attribute: 'auto_boot', type: 'boolean' },
        'Virt Bridge' => { attribute: 'bridge', type: 'string' },
        'Virt CPUs' => { attribute: 'cpus', type: 'string' },
        'Virt Disk Driver Type' => { attribute: 'disk_driver_type', type: 'string' },
        'Virt File Size (GB)' => { attribute: 'disk_size', type: 'string' },
        'Virt Path' => { attribute: 'disk_path', type: 'string' },
        'Virt RAM (MB)' => { attribute: 'ram', type: 'string' },
        'Virt Type' => { attribute: 'virtualization_type', type: 'string' }
      }.freeze
    end

    unless defined? PROFILE_FIELDS
      PROFILE_FIELDS = {
        'Name' => { attribute: 'base_name', type: 'string' },
        # Parse as JSON
        'TFTP Boot Files' => { attribute: 'boot_files', type: 'array' },
        'Comment' => { attribute: 'comment', type: 'string' },
        'DHCP Tag' => { attribute: 'dhcp_tag', type: 'string' },
        'Distribution' => { attribute: 'distro', type: 'string' },
        'Enable gPXE?' => { attribute: 'enable_gpxe', type: 'string' },
        'Enable PXE Menu?' => { attribute: 'enable_pxe_menu', type: 'string' },
        # Parse as JSON
        'Fetchable Files' => { attribute: 'fetchable_files', type: 'hash' },
        # Parse as JSON
        'Kernel Options' => { attribute: 'kernel_options', type: 'hash' },
        # Parse as JSON
        'Kernel Options (Post Install)' => { attribute: 'kernel_options_postinstall', type: 'hash' },
        # Parse as JSON
        'Kickstart Metadata' => { attribute: 'kickstart_meta', type: 'hash' },
        # Strip braces and parse as CSV
        'Management Classes' => { attribute: 'mgmt_classes', type: 'array' },
        'Management Parameters' => { attribute: 'mgmt_parameters', type: 'string' },
        # Strip braces and parse as CSV
        'Name Servers' => { attribute: 'name_servers', type: 'array' },
        'Name Servers Search Path' => { attribute: 'name_servers_search_path', type: 'string' },
        # Strip braces and parse as CSV
        'Owners' => { attribute: 'owners', type: 'array' },
        'Parent Profile' => { attribute: 'parent_profile', type: 'string' },
        'Internal Proxy' => { attribute: 'internal_proxy', type: 'string' },
        'Red Hat Management Key' => { attribute: 'redhat_management_key', type: 'string' },
        'Red Hat Management Server' => { attribute: 'redhat_management_server', type: 'string' },
        'Repos' => { attribute: 'repos', type: 'array' },
        'Server Override' => { attribute: 'server_override', type: 'string' },
        # Parse as JSON
        'Template Files' => { attribute: 'template_files', type: 'hash' },
        'Virt Auto Boot' => { attribute: 'auto_boot', type: 'string' },
        'Virt Bridge' => { attribute: 'bridge', type: 'string' },
        'Virt CPUs' => { attribute: 'cpus', type: 'string' },
        'Virt Disk Driver Type' => { attribute: 'disk_driver_type', type: 'string' },
        'Virt File Size (GB)' => { attribute: 'disk_size', type: 'string' },
        'Virt Path' => { attribute: 'disk_path', type: 'string' },
        'Virt RAM (MB)' => { attribute: 'ram', type: 'string' },
        'Virt Type' => { attribute: 'virtualization_type', type: 'string' }
      }.freeze
    end

    unless defined? REPOSITORY_FIELDS
      REPOSITORY_FIELDS = {
        'Name' => { attribute: 'base_name', type: 'string' },
        'Owners' => { attribute: 'owners', type: 'array' },
        'Arch' => { attribute: 'architecture', type: 'string' },
        'Breed' => { attribute: 'os_breed', type: 'string' },
        'Mirror' => { attribute: 'mirror_url', type: 'string' },
        'Comment' => { attribute: 'comment', type: 'string' },
        'Keep Updated' => { attribute: 'keep_updated', type: 'boolean' },
        'RPM List' => { attribute: 'rpm_list', type: 'array' },
        'External proxy URL' => { attribute: 'proxy_url', type: 'string' },
        'Apt Components (apt only)' => { attribute: 'apt_components', type: 'string' },
        'Apt Dist Names (apt only)' => { attribute: 'apt_dist_names', type: 'string' },
        'Createrepo Flags' => { attribute: 'createrepo_flags', type: 'string' },
        'Environment Variables' => { attribute: 'env_variables', type: 'hash' },
        'Mirror locally' => { attribute: 'mirror_locally', type: 'boolean' },
        'Priority' => { attribute: 'priority', type: 'string' },
        'Yum Options' => { attribute: 'yum_options', type: 'hash' }
      }.freeze
    end

    unless defined? SYSTEM_FIELDS
      SYSTEM_FIELDS = {
      }.freeze
    end

    # Load the details for an existing distro from the Cobbler system
    def load_distro(distro)
      shellout = Mixlib::ShellOut.new("cobbler distro report --name='#{distro}'")
      shellout.run_command
      rc = "Return code: #{shellout.exitstatus}"
      stdout = "Stdout: #{shellout.stdout.chomp}"
      stderr = "Stderr: #{shellout.stderr.chomp}"
      if shellout.error?
        Chef::Log.fatal("Cobbler execution for failed with:\n#{stderr}\n#{stdout}\n#{rc}")
        raise "Cobbler execution failed with #{stderr} (RC=#{rc})"
      end

      resource = Chef::Resource::CobblerdDistro.new(distro)
      raw_info = shellout.stdout.split("\n")
      raw_info.each do |line_item|
        line_item.chomp!
        parts = line_item.split(':')
        parts[0].strip!
        parts[1].strip!

        next unless DISTRO_FIELDS.key?(parts[0])
        field_name = DISTRO_FIELDS[parts[0]][:attribute]
        value = case DISTRO_FIELDS[parts[0]][:type]
                when 'hash'
                  # Parse as JSON
                  JSON.parse(parts[1])
                when 'array'
                  if parts[1] == '[]'
                    nil
                  else
                    # Strip braces and parse as CSV
                    parts[1][1..-1].split(',')
                  end
                when 'boolean'
                  if parts[1] == '1' || parts[1] == 'true' || parts[1] == 'True'
                    true
                  else
                    false
                  end
                else
                  (parts[1] == '<<inherit>>' ? '' : parts[1].chomp)
                end
        resource.send("#{field_name}=", value)
      end

      resource
    end

    # Load the details for an existing image from the Cobbler system
    def load_image(image)
      shellout = Mixlib::ShellOut.new("cobbler image report --name='#{image}'")
      shellout.run_command
      rc = "Return code: #{shellout.exitstatus}"
      stdout = "Stdout: #{shellout.stdout.chomp}"
      stderr = "Stderr: #{shellout.stderr.chomp}"
      if shellout.error?
        Chef::Log.fatal("Cobbler execution failed with:\n#{stderr}\n#{stdout}\n#{rc}")
        raise "Cobbler execution failed with #{stderr} (RC=#{rc})"
      end

      resource = Chef::Resource::CobblerdImage.new(image)
      raw_info = shellout.stdout.split("\n")
      raw_info.each do |line_item|
        line_item.chomp!
        parts = line_item.split(':')
        parts[0].strip!
        parts[1].strip!

        next unless IMAGE_FIELDS.key?(parts[0])
        field_name = IMAGE_FIELDS[parts[0]][:attribute]
        value = case IMAGE_FIELDS[parts[0]][:type]
                when 'hash'
                  # Parse as JSON
                  JSON.parse(parts[1])
                when 'array'
                  if parts[1] == '[]'
                    nil
                  else
                    # Strip braces and parse as CSV
                    parts[1][1..-1].split(',')
                  end
                when 'boolean'
                  if parts[1] == '1' || parts[1] == 'true' || parts[1] == 'True'
                    true
                  else
                    false
                  end
                else
                  (parts[1] == '<<inherit>>' ? '' : parts[1].chomp)
                end
        resource.send("#{field_name}=", value)
      end

      resource
    end

    # Load the details for an existing profile from the Cobbler system
    def load_profile(profile)
      shellout = Mixlib::ShellOut.new("cobbler profile report --name='#{profile}'")
      shellout.run_command
      rc = "Return code: #{shellout.exitstatus}"
      stdout = "Stdout: #{shellout.stdout.chomp}"
      stderr = "Stderr: #{shellout.stderr.chomp}"
      if shellout.error?
        Chef::Log.fatal("Cobbler execution failed with:\n#{stderr}\n#{stdout}\n#{rc}")
        raise "Cobbler execution failed with #{stderr} (RC=#{rc})"
      end

      resource = Chef::Resource::CobblerdProfile.new(image)
      raw_info = shellout.stdout.split("\n")
      raw_info.each do |line_item|
        line_item.chomp!
        parts = line_item.split(':')
        parts[0].strip!
        parts[1].strip!

        next unless PROFILE_FIELDS.key?(parts[0])
        field_name = PROFILE_FIELDS[parts[0]][:attribute]
        value = case PROFILE_FIELDS[parts[0]][:type]
                when 'hash'
                  # Parse as JSON
                  JSON.parse(parts[1])
                when 'array'
                  if parts[1] == '[]'
                    nil
                  else
                    # Strip braces and parse as CSV
                    parts[1][1..-1].split(',')
                  end
                when 'boolean'
                  if parts[1] == '1' || parts[1] == 'true' || parts[1] == 'True'
                    true
                  else
                    false
                  end
                else
                  (parts[1] == '<<inherit>>' ? '' : parts[1].chomp)
                end
        resource.send("#{field_name}=", value)
      end

      resource
    end

    def load_repo(repo)
      shellout = Mixlib::ShellOut.new("cobbler repo report --name='#{repo}'")
      shellout.run_command
      rc = "Return code: #{shellout.exitstatus}"
      stdout = "Stdout: #{shellout.stdout.chomp}"
      stderr = "Stderr: #{shellout.stderr.chomp}"
      if shellout.error?
        Chef::Log.fatal("Cobbler execution failed with:\n#{stderr}\n#{stdout}\n#{rc}")
        raise "Cobbler execution failed with #{stderr} (RC=#{rc})"
      end

      resource = Chef::Resource::CobblerdRepo.new(repo)
      raw_info = shellout.stdout.split("\n")
      raw_info.each do |line_item|
        line_item.chomp!
        parts = line_item.split(':')
        parts[0].strip!
        parts[1].strip!

        next unless REPOSITORY_FIELDS.key?(parts[0])
        field_name = REPOSITORY_FIELDS[parts[0]][:attribute]
        value = case REPOSITORY_FIELDS[parts[0]][:type]
                when 'hash'
                  # Parse as JSON
                  JSON.parse(parts[1])
                when 'array'
                  if parts[1] == '[]'
                    nil
                  else
                    # Strip braces and parse as CSV
                    parts[1][1..-1].split(',')
                  end
                when 'boolean'
                  if parts[1] == '1' || parts[1] == 'true' || parts[1] == 'True'
                    true
                  else
                    false
                  end
                else
                  (parts[1] == '<<inherit>>' ? '' : parts[1].chomp)
                end
        resource.send("#{field_name}=", value)
      end

      resource
    end

    def load_system(system)
      shellout = Mixlib::ShellOut.new("cobbler system report --name='#{system}'")
      shellout.run_command
      rc = "Return code: #{shellout.exitstatus}"
      stdout = "Stdout: #{shellout.stdout.chomp}"
      stderr = "Stderr: #{shellout.stderr.chomp}"
      if shellout.error?
        Chef::Log.fatal("Cobbler execution failed with:\n#{stderr}\n#{stdout}\n#{rc}")
        raise "Cobbler execution failed with #{stderr} (RC=#{rc})"
      end

      resource = Chef::Resource::CobblerdSystem.new(system)
      raw_info = shellout.stdout.split("\n")
      raw_info.each do |line_item|
        line_item.chomp!
        parts = line_item.split(':')
        parts[0].strip!
        parts[1].strip!

        next unless SYSTEM_FIELDS.key?(parts[0])
        field_name = SYSTEM_FIELDS[parts[0]][:attribute]
        value = case SYSTEM_FIELDS[parts[0]][:type]
                when 'hash'
                  # Parse as JSON
                  JSON.parse(parts[1])
                when 'array'
                  if parts[1] == '[]'
                    nil
                  else
                    # Strip braces and parse as CSV
                    parts[1][1..-1].split(',')
                  end
                when 'boolean'
                  if parts[1] == '1' || parts[1] == 'true' || parts[1] == 'True'
                    true
                  else
                    false
                  end
                else
                  (parts[1] == '<<inherit>>' ? '' : parts[1].chomp)
                end

        resource.send("#{field_name}=", value)
      end

      resource
    end

    # Parse Cobbler distro report output
    # Params:
    # +distro+:: the cobbler distro to get data for
    # +field+:: the field to return
    def cobbler_distro(distro, field)
      # Arguments: distro --
      #            field --
      # Acquire Cobbler output like:
      # Name                           : centos-6-x86_64
      # Architecture                   : x86_64
      # Breed                          : redhat
      # [...]
      distro_chk = Mixlib::ShellOut.new("cobbler distro report --name='#{distro}'")
      distro_chk.run_command
      rc = "Return code: #{distro_chk.exitstatus}"
      stdout = "Stdout: #{distro_chk.stdout.chomp}"
      stderr = "Stderr: #{distro_chk.stderr.chomp}"
      Chef::Application.fatal!("Cobbler failed with:\n#{stderr}\n#{stdout}\n#{rc}") if distro_chk.error?
      raw_distro_info = distro_chk.stdout
      raw_field_line = raw_distro_info.each_line.select { |l| l if l.chomp.start_with?(field) }
      raw_field_line.first.split(' : ')[1].chomp
    end
  end
end
