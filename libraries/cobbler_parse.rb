module Cobbler
  # Parse Cobbler output
  module Parse
    include Chef::Mixin::ShellOut

    DISTRO_FIELDS = {
      'Name' => 'base_name',
      'Architecture' => 'architecture',
      # Parse as JSON
      'TFTP Boot Files' => 'boot_files',
      'Breed' => 'breed',
      'Comment' => 'comment',
      # Parse as JSON
      'Fetchable Files' => 'fetchable_files',
      'Initrd' => 'initrd',
      'Kernel' => 'kernel',
      # Parse as JSON
      'Kernel Options' => 'kernel_options',
      # Parse as JSON
      'Kernel Options (Post Install)' => 'kernel_options_postinstall',
      # Parse as JSON
      'Kickstart Metadata' => 'kickstart_meta',
      # Strip braces and parse as CSV
      'Management Classes' => 'mgmt_classes',
      'OS Version' => 'os_version',
      # Strip braces and parse as CSV
      'Owners' => 'owners',
      'Red Hat Management Key' => 'redhat_management_key',
      'Red Hat Management Server' => 'redhat_management_server',
      # Parse as JSON
      'Template Files' => 'template_files'
    }.freeze

    IMAGE_FIELDS = {
      'Name' => 'base_name',
      'Architecture' => 'architecture',
      'Breed' => 'breed',
      'Comment' => 'comment',
      'File' => 'file',
      'Image Type' => 'image_type',
      'Kickstart' => 'kickstart',
      'Virt NICs' => 'virtual_nics',
      'OS Version' => 'os_version',
      # Strip braces and parse as CSV
      'Owners' => 'owners',
      'Parent' => 'parent',
      'Virt Auto Boot' => 'auto_boot',
      'Virt Bridge' => 'bridge',
      'Virt CPUs' => 'cpus',
      'Virt Disk Driver Type' => 'disk_driver_type',
      'Virt File Size (GB)' => 'disk_size',
      'Virt Path' => 'disk_path',
      'Virt RAM (MB)' => 'ram',
      'Virt Type' => 'virtualization_type'
    }.freeze

    PROFILE_FIELDS = {
      'Name' => 'base_name',
      # Parse as JSON
      'TFTP Boot Files' => 'boot_files',
      'Comment' => 'comment',
      'DHCP Tag' => 'dhcp_tag',
      'Distribution' => 'distribution',
      'Enable gPXE?' => 'enable_gpxe',
      'Enable PXE Menu?' => 'enable_pxe_menu',
      # Parse as JSON
      'Fetchable Files' => 'fetchable_files',
      # Parse as JSON
      'Kernel Options' => 'kernel_options',
      # Parse as JSON
      'Kernel Options (Post Install)' => 'kernel_options_postinstall',
      # Parse as JSON
      'Kickstart Metadata' => 'kickstart_meta',
      # Strip braces and parse as CSV
      'Management Classes' => 'mgmt_classes',
      'Management Parameters' => 'mgmt_parameters',
      # Strip braces and parse as CSV
      'Name Servers' => 'name_servers',
      'Name Servers Search Path' => 'name_servers_search_path',
      # Strip braces and parse as CSV
      'Owners' => 'owners',
      'Parent Profile' => 'parent_profile',
      'Internal Proxy' => 'internal_proxy',
      'Red Hat Management Key' => 'redhat_management_key',
      'Red Hat Management Server' => 'redhat_management_server',
      'Repos' => 'repos',
      'Server Override' => 'server_override',
      # Parse as JSON
      'Template Files' => 'template_files',
      'Virt Auto Boot' => 'auto_boot',
      'Virt Bridge' => 'bridge',
      'Virt CPUs' => 'cpus',
      'Virt Disk Driver Type' => 'disk_driver_type',
      'Virt File Size (GB)' => 'disk_size',
      'Virt Path' => 'disk_path',
      'Virt RAM (MB)' => 'ram',
      'Virt Type' => 'virtualization_type'
    }.freeze

    SYSTEM_FIELDS = {
    }.freeze

    def load_distro(distro)
      shellout = Mixlib::ShellOut.new("cobbler distro report --name='#{distro}'")
      shellout.run_command
      rc = "Return code: #{shellout.exitstatus}"
      stdout = "Stdout: #{shellout.stdout.chomp}"
      stderr = "Stderr: #{shellout.stderr.chomp}"
      Chef::Application.fatal!("Cobbler failed with:\n#{stderr}\n#{stdout}\n#{rc}") if shellout.error?

      resource = Chef::Resource::CobblerdDistro.new(distro)
      raw_info = shellout.stdout
      raw_info.each do |line_item|
        line_item.chomp!
        parts = line_item.split(':')
        parts[0].strip!
        parts[1].strip!

        if DISTRO_FIELDS.key?(parts[0])
          field_name = DISTRO_FIELDS[parts[0]]
          resource.send("#{field_name}=", parts[1])
        end
      end

      resource
    end

    def load_image(image)
      shellout = Mixlib::ShellOut.new("cobbler image report --name='#{image}'")
      shellout.run_command
      rc = "Return code: #{shellout.exitstatus}"
      stdout = "Stdout: #{shellout.stdout.chomp}"
      stderr = "Stderr: #{shellout.stderr.chomp}"
      Chef::Application.fatal!("Cobbler failed with:\n#{stderr}\n#{stdout}\n#{rc}") if shellout.error?

      resource = Chef::Resource::CobblerdImage.new(image)
      raw_info = shellout.stdout
      raw_info.each do |line_item|
        line_item.chomp!
        parts = line_item.split(':')
        parts[0].strip!
        parts[1].strip!

        if IMAGE_FIELDS.key?(parts[0])
          field_name = IMAGE_FIELDS[parts[0]]
          resource.send("#{field_name}=", parts[1])
        end
      end

      resource
    end

    def load_profile(profile)
      shellout = Mixlib::ShellOut.new("cobbler profile report --name='#{profile}'")
      shellout.run_command
      rc = "Return code: #{shellout.exitstatus}"
      stdout = "Stdout: #{shellout.stdout.chomp}"
      stderr = "Stderr: #{shellout.stderr.chomp}"
      Chef::Application.fatal!("Cobbler failed with:\n#{stderr}\n#{stdout}\n#{rc}") if shellout.error?

      resource = Chef::Resource::CobblerdProfile.new(image)
      raw_info = shellout.stdout
      raw_info.each do |line_item|
        line_item.chomp!
        parts = line_item.split(':')
        parts[0].strip!
        parts[1].strip!

        if PROFILE_FIELDS.key?(parts[0])
          field_name = PROFILE_FIELDS[parts[0]]
          resource.send("#{field_name}=", parts[1])
        end
      end

      resource
    end

    def load_repo(repo)
      shellout = Mixlib::ShellOut.new("cobbler repo report --name='#{repo}'")
      shellout.run_command
      rc = "Return code: #{shellout.exitstatus}"
      stdout = "Stdout: #{shellout.stdout.chomp}"
      stderr = "Stderr: #{shellout.stderr.chomp}"
      Chef::Application.fatal!("Cobbler failed with:\n#{stderr}\n#{stdout}\n#{rc}") if shellout.error?

      resource = Chef::Resource::CobblerdRepo.new(repo)
      raw_info = shellout.stdout
      raw_info.each do |line_item|
        line_item.chomp!
        parts = line_item.split(':')
        parts[0].strip!
        parts[1].strip!

        if REPOSITORY_FIELDS.key?(parts[0])
          field_name = REPOSITORY_FIELDS[parts[0]]
          resource.send("#{field_name}=", parts[1])
        end
      end

      resource
    end

    def load_system(system)
      shellout = Mixlib::ShellOut.new("cobbler system report --name='#{system}'")
      shellout.run_command
      rc = "Return code: #{shellout.exitstatus}"
      stdout = "Stdout: #{shellout.stdout.chomp}"
      stderr = "Stderr: #{shellout.stderr.chomp}"
      Chef::Application.fatal!("Cobbler failed with:\n#{stderr}\n#{stdout}\n#{rc}") if shellout.error?

      resource = Chef::Resource::CobblerdSystem.new(system)
      raw_info = shellout.stdout
      raw_info.each do |line_item|
        line_item.chomp!
        parts = line_item.split(':')
        parts[0].strip!
        parts[1].strip!

        if SYSTEM_FIELDS.key?(parts[0])
          field_name = SYSTEM_FIELDS[parts[0]]
          resource.send("#{field_name}=", parts[1])
        end
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
