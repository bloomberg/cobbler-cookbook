require 'spec_helper'

describe 'cobblerd_test::create_distros' do
  include_context 'recipe variables'
  platforms.each do |platform, details|
    versions = details['versions']
    versions.each do |version|
      # before do
      #  before { Mixlib::ShellOut.stub(:new).and_return(shellout, run_command: nil) }
      # end

      # TODO: Tests required: create new, attempt to create over existing.
      # TODO: To test existing, need to stub the @current_resource load.
      # TODO: To test existing, need to stub the cobbler find / cobbler list command.
      context "On #{platform} #{version}" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: platform, version: version, step_into: ['cobblerd_distro'])
          runner.node.override['environment'] = 'dev'
          runner.converge(described_recipe)
        end

        it 'should run the "cobbler add" statement' do
          os_versions.each do |vers|
            osver = vers.gsub(/\.[0-9].*/, '')
            comment = "Test comment for distro-centos-#{vers} distro"

            expect(chef_run).to create_cobblerd_distro("centos-#{vers}")
              .with(kernel: kernel(vers))
              .with(initrd: initrd(vers))
              .with(boot_files: boot_file_hash)
              .with(architecture: arch)
              .with(os_breed: breed)
              .with(os_version: os_vers)
              .with(comment: comment)

            command =  "      cobbler distro add --name=centos-#{vers} --owners='admin' --kernel=#{kernel(vers)}"
            command += " --initrd=#{initrd(vers)} --arch=#{arch} --breed=#{breed} --os-version=#{os_vers}"
            command += " --comment='#{comment}' --boot-files=#{boot_files.join(',')}\n"
            expect(chef_run).to run_bash("centos-#{vers}-cobbler-distro-add")
              .with(code: command)
          end
        end
      end
    end
  end
end
