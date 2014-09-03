module Cobbler
  module Parse

    include Chef::Mixin::ShellOut

    def cobbler_distro(distro, field)
      # Parse Cobbler distro report output
      # Arguments: distro -- the cobbler distro to get data for
      #            field -- the field to return
      # Acquire Cobbler output like:
      # Name                           : centos-6-x86_64
      # Architecture                   : x86_64
      # Breed                          : redhat
      # [...]
      distro_chk = Mixlib::ShellOut.new("cobbler distro report --name='#{distro}'")
      distro_chk.run_command 
      Chef::Application.fatal!("Cobbler failed with:\nStderr: #{distro_chk.stderr.chomp}\nStdout: #{distro_chk.stdout.chomp}\nReturn code: #{distro_chk.exitstatus}") if distro_chk.error?
      raw_distro_info = distro_chk.stdout
      raw_field_line = raw_distro_info.each_line.select { |l| l if l.chomp.start_with?(field) }
      return raw_field_line.first.split(' : ')[1].chomp
    end
  end
end
